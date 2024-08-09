pipeline {
    agent none // Do not use agent at the pipeline level

    environment {
        SSH_KEY_PATH = '/var/lib/jenkins/.ssh/id_rsa' // Path to your private SSH key inside the Jenkins container
        TERRAFORM_VERSION = 'Terraform' // Specify the name you defined in the tool configuration
        ANSIBLE_VERSION = 'Ansible' // Specify the name you defined in the tool configuration
    }

    stages {
        stage('Check Terraform Version') {
            agent { label 'master' } // Run on the master node
            tools {
                terraform "${env.TERRAFORM_VERSION}" // Use the Terraform tool
            }
            steps {
                script {
                    sh 'terraform --version' // Check Terraform version
                }
            }
        }

        stage('Terraform Init & Apply') {
            agent { label 'master' } // Run on the master node
            tools {
                terraform "${env.TERRAFORM_VERSION}" // Use the Terraform tool
            }
            steps {
                script {
                        sh 'terraform init' // Initialize Terraform
                        sh 'terraform apply -auto-approve' // Apply Terraform configuration
                    
                }
            }
        }
        
        stage('Generate Ansible Inventory') {
            agent { label 'master' } // Run on the master node
            steps {
                script {
                    def buildNodeIp = sh(script: 'terraform output -raw build_node_ip', returnStdout: true).trim() // Get build node IP
                    def prodNodeIp = sh(script: 'terraform output -raw prod_node_ip', returnStdout: true).trim() // Get production node IP

                    writeFile file: 'inventory', text: """
[build_node]
${buildNodeIp} ansible_user=jenkins ansible_ssh_private_key_file=${SSH_KEY_PATH} ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[prod_node]
${prodNodeIp} ansible_user=jenkins ansible_ssh_private_key_file=${SSH_KEY_PATH} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
                    """ // Create Ansible inventory file
                }
            }
        }

        stage('Setup Build Node') {
            agent { label 'master' } // Build node setup runs on Jenkins Master
             tools {
                ansible "${env.ANSIBLE_VERSION}" // Use the Ansible tool
             }
            steps {
                script {
                        sh 'ansible-playbook -i inventory ansible-build_node.yml --private-key=${SSH_KEY_PATH}' // Run playbook for the build node
                }
            }
        }

        

        stage('Setup Prod Node') {
            agent { label 'master' } // Production node setup runs on Jenkins Master
            tools {
                ansible "${env.ANSIBLE_VERSION}" // Use the Ansible tool
             }
            steps {
                script {
                        sh 'ansible-playbook -i inventory ansible-prod_node.yml --private-key=${SSH_KEY_PATH}' // Run playbook for the production node
                    
                }
            }
        }
     }    
}
