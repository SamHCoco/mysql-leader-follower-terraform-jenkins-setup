pipeline {
    agent any

    environment {
        AWS_PROFILE = 'default'
        REGION = 'eu-west-2'
        TF_VAR_aws_access_key = credentials('aws_access_key')
        TF_VAR_aws_secret_key = credentials('aws_secret_key')
    }

    stages {
        stage('Terraform Init') {
            steps {
                script {
                    // Initialize Terraform to set up the environment
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                script {
                    // Apply Terraform to create AWS resources
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Retrieve IPs') {
            steps {
                script {
                    // Capture the output variables from Terraform
                    def master_ip = sh(script: 'terraform output -raw master_ip', returnStdout: true).trim()
                    def slave_ip = sh(script: 'terraform output -raw slave_ip', returnStdout: true).trim()
                    // Store them as environment variables for Ansible
                    env.MASTER_IP = master_ip
                    env.SLAVE_IP = slave_ip
                }
            }
        }
        
        stage('Configure MySQL Replication with Ansible') {
            steps {
                script {
                    // Create Ansible inventory dynamically
                    writeFile file: 'inventory', text: """
                    [master]
                    ${env.MASTER_IP}

                    [slave]
                    ${env.SLAVE_IP}
                    """

                    // Run Ansible playbook to configure MySQL replication
                    sh 'ansible-playbook -i inventory mysql_replication.yml'
                }
            }
        }
    }

    post {
        always {
            script {
                // Destroy infrastructure after testing (optional)
                sh 'terraform destroy -auto-approve'
            }
        }
    }
}
