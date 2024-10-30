pipeline {
    agent any

    environment {
        REGION = 'eu-west-2'
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage('Create Master Slave DBs') {
            steps {
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Retrieve Master Slave IPs') {
            steps {
                script {
                    def master_ip = sh(script: 'terraform output -raw master_ip', returnStdout: true).trim()
                    def slave_ip = sh(script: 'terraform output -raw slave_ip', returnStdout: true).trim()
                    env.MASTER_IP = master_ip
                    env.SLAVE_IP = slave_ip
                }
            }
        }

        stage('Setup Replication') {
            environment {
                ANSIBLE_HOST_KEY_CHECKING = 'False'
            }
            steps {
                script {
                    writeFile file: 'inventory', text: """
                    [master]
                    ${env.MASTER_IP}

                    [slave]
                    ${env.SLAVE_IP}
                    """
                }
                // Use the SSH key stored under ID 'EC2_PEM'
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'EC2_PEM', keyFileVariable: 'SSH_KEY_FILE', usernameVariable: 'EC2_USER'),
                    usernamePassword(credentialsId: 'MYSQL_ROOT_CREDENTIALS_ID', passwordVariable: 'MYSQL_ROOT_PASSWORD', usernameVariable: 'MYSQL_ROOT_USER'),
                    string(credentialsId: 'REPLICATION_USER_ID', variable: 'REPLICATION_USER'),
                    string(credentialsId: 'REPLICATION_PASSWORD_ID', variable: 'REPLICATION_PASSWORD')
                ]) {
                    sh '''
                    ansible-playbook -i inventory \
                        --private-key $SSH_KEY_FILE \
                        -vvv \
                        -u $EC2_USER \
                        --extra-vars "mysql_user=$MYSQL_ROOT_USER \
                                      mysql_root_password=$MYSQL_ROOT_PASSWORD \
                                      replication_user=$REPLICATION_USER \
                                      replication_password=$REPLICATION_PASSWORD" \
                        mysql_replication.yml
                    '''
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
