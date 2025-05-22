pipeline {
    agent any
    tools {
        terraform 'terraform'
    }
    parameters {
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
    }
    triggers {
        cron('H 0 * * *') // Runs every day at midnight
    }
    environment {
        SLACKCHANNEL = '21st-april-sock-shop-project-team-2'
        SLACKCREDENTIALS = credentials('slack')
    }
    
    stages {
        stage('IAC Scan') {
            steps {
                script {
                    sh 'pip install pipenv'
                    sh 'pipenv run pip install checkov'
                    def checkovStatus = sh(script: 'pipenv run checkov -d . -o cli --output-file checkov-results.txt --quiet', returnStatus: true)
                    junit allowEmptyResults: true, testResults: 'checkov-results.txt' 
                    // if (checkovStatus != 0) {
                    //     error 'Checkov found some issues'
                    // }
                }
            }
        }
        stage('Terraform Init') {  // Fixed spelling
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform format') {
            steps {
                sh 'terraform fmt --recursive'
            }
        }
        stage('Terraform validate') {
            steps {
                sh 'terraform validate'
            }
        }
        stage('Terraform plan') {
            steps {
                sh 'terraform plan'
            }
        }
        stage('Terraform action') {
            steps {
                script {
                    sh "terraform ${action} -auto-approve"
                }
            }
        }
    }
    post {
        always {
            script {
                slackSend(
                    channel: SLACKCHANNEL,
                    color: currentBuild.result == 'SUCCESS' ? 'good' : 'danger',
                    message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL}) has been completed."
                )
            }
        }
        failure {
            slackSend(
                channel: SLACKCHANNEL,
                color: 'danger',
                message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' has failed. Check console output at ${env.BUILD_URL}."
            )
        }
        success {
            slackSend(
                channel: SLACKCHANNEL,
                color: 'good',
                message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' completed successfully. Check console output at ${env.BUILD_URL}."
            )
        }
    }
}
