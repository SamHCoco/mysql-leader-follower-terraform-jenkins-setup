pipeline {
    agent any

    environment {
        REGION = 'eu-west-2'
    }

    stages {
        stage('Setup AWS Credentials') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                   accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                   secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                                   credentialsId: 'aws-credentials-id']]) {

                    script {
                        // Export AWS credentials as Terraform expects them
                        env.TF_VAR_aws_access_key = '$AWS_ACCESS_KEY_ID'
                        env.TF_VAR_aws_secret_key = '$AWS_SECRET_ACCESS_KEY'
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Retrieve IPs') {
            steps {
                script {
                    def master_ip = sh(script: 'terraform output -raw master_ip', returnStdout: true).trim()
                    def slave_ip = sh(script: 'terraform output -raw slave_ip', returnStdout: true).trim()
                    env.MASTER_IP = master_ip
                    env.SLAVE_IP = slave_ip
                }
            }
        }

        stage('MySQL Replication with Ansible') {
            steps {
                script {
                    writeFile file: 'inventory', text: """
                    [master]
                    ${env.MASTER_IP}

                    [slave]
                    ${env.SLAVE_IP}
                    """
                    sh 'ansible-playbook -i inventory mysql_replication.yml'
                }
            }
        }
    }

    post {
        always {
            sh 'terraform destroy -auto-approve'
        }
    }
}
