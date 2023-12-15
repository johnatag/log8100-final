pipeline {
 agent any
 
 environment {
    DISCORD_WEBHOOK = credentials('webhook_url')
 }

 stages {

    stage('Stash Terraform code') {
        steps {
            git url: 'https://github.com/johnatag/log8100-final.git', branch: 'main'
            stash includes: 'terraform/**', name: 'my-terraform-code'
        }
    }

    stage('TFLint scan') {
        steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                // Your commands here
                script {
                    docker.image('ghcr.io/terraform-linters/tflint:latest').inside("--entrypoint='' -w /var/jenkins_home/workspace/log8100") {
                        unstash 'my-terraform-code'
                        try {
                            sh 'tflint --init > tflint.xml'
                            junit skipPublishingChecks: true, testResults: 'tflint.xml'
                        } catch (err) {
                            junit skipPublishingChecks: true, testResults: 'tflint.xml'
                            throw err
                        }
                    }
                }
            }
        }
        post {
            always {
                archiveArtifacts artifacts: 'tflint.xml', fingerprint: true
            }

            success {
                discordSend description: "TFLint stage", footer: "TFLint scann successful", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
            }
  
            failure {
                discordSend description: "TFLint stage", footer: "TFLint scan failed", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
            }
        }
    }

    stage('Checkov scan') {
        steps {
            
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                // Your commands here
                script {
                    docker.image('bridgecrew/checkov:latest').inside("--entrypoint='' -w /var/jenkins_home/workspace/log8100") {
                        unstash 'my-terraform-code'
                        try {
                            sh 'checkov -d . -o cli -o junitxml --output-file-path console,checkov_scan.xml --repo-id johnatag/log8100-final --branch main'
                            junit skipPublishingChecks: true, testResults: 'checkov_scan.xml'
                        } catch (err) {
                            junit skipPublishingChecks: true, testResults: 'checkov_scan.xml'
                            throw err
                        }
                    }
                }
            }
        }
        post {
            always {
                archiveArtifacts artifacts: 'checkov_scan.xml', fingerprint: true
            }

            success {
                discordSend description: "Checkov Scan stage", footer: "Checkov Scan success", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
            }
  
            failure {
                discordSend description: "Checkov Scan stage", footer: "Checkov Scan failed", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
            }
        }
    }


    stage('Terrascan scan') {
        steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                // Your commands here
                script {
                    docker.image('tenable/terrascan:latest').inside("--entrypoint='' -u root -w /var/jenkins_home/workspace/log8100 -e HOME=/var/jenkins_home") {
                        unstash 'my-terraform-code'
                        try {
                            sh 'terrascan init'
                            sh 'terrascan scan -x console -o junit-xml > terrascan.xml'
                            junit skipPublishingChecks: true, testResults: 'terrascan.xml'
                        } catch (err) {
                            junit skipPublishingChecks: true, testResults: 'terrascan.xml'
                            throw err
                        }
                    }
                }
            }
        }
        post {
            always {
                archiveArtifacts artifacts: 'terrascan.xml', fingerprint: true
            }

            success {
                discordSend description: "Terrascan stage", footer: "Terrascan success", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
            }
  
            failure {
                discordSend description: "Terrascan stage", footer: "Terrascan failed", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
            }
        }
    }


    stage('Terraform fmt') {
        steps {
            
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                // Your commands here
                script {
                    docker.image('hashicorp/terraform:latest').inside("--entrypoint='' -w /var/jenkins_home/workspace/log8100") {
                        unstash 'my-terraform-code'
                        sh 'terraform fmt -recursive -diff > terraform.diff'
                    }
                }
            }
        }
        post {
            always {
                archiveArtifacts artifacts: 'terraform.diff', fingerprint: true
            }

            success {
                discordSend description: "Terraform fmt stage", footer: "Terraform fmt success", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
            }
  
            failure {
                discordSend description: "Terraform fmt stage", footer: "Terrascan fmt failed", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
            }
        }
    }

    stage('Build') {
        steps {
            script {
                try {
                    dockerImage = docker.build("floatdocka/juicebox-log8100:${env.BUILD_ID}")
                } catch (e) {
                    echo "An error occured: ${e}"
                }
                
            }
        }

        post {
            success {
                discordSend description: "Docker Build Stage", footer: "Docker Build success", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
            }
  
            failure {
                discordSend description: "Docker Build Stage", footer: "Docker Build failed", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
            }
        }
    }

    stage('Trivy Scan') {
    steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            // Your commands here
            script {
                sh '''
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image floatdocka/juicebox-log8100:${BUILD_ID} -o json > trivy.json
                '''
            }
        } 
    }
    post {
        always {
            archiveArtifacts artifacts: 'trivy.json', fingerprint: true
        }

        success {
            discordSend description: "Trivy Scan Stage", footer: "Trivy Scan success", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
        }
  
        failure {
            discordSend description: "Trivy Scan Stage", footer: "Trivy Scan failed", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
        } 
    }
}

stage('Clair Scan') {
   steps {
       catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
           // Your commands here
           script {
               sh '''
                    docker compose up -d
                    docker compose exec clairctl clairctl report -l juicebox-log8100:${BUILD_ID}
               '''
           }
       }
   }
   post {
       always {
          archiveArtifacts artifacts: 'clair.json', fingerprint: true
       }

        success {
            discordSend description: "Clair Scan Stage", footer: "Clair Scan success", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
        }

        failure {
            discordSend description: "Clair Scan Stage", footer: "Clair Scan failed", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
        }
   }
}
    stage('Push') {
        steps {
            script {
                try {
                    docker.withRegistry('', 'dockerhub') {
                            dockerImage.push()
                            dockerImage.push("latest")
                    }
                } catch (e) {
                    echo "An error occured: ${e}"
                }
            }
        }

    post {
        success {
            discordSend description: "Docker Push Stage", footer: "Docker Push success", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
        }

        failure {
            discordSend description: "Docker Push Stage", footer: "Docker Push failed", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
        }
   }
    }

    stage('ZAP Scan') {
        steps {
            
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                // Your commands here
                script {
                    sh '''
                        docker run -t -v ${WORKSPACE}:/zap/wrk owasp/zap2docker-stable zap-baseline.py -t https://demo.owasp-juice.shop/ -r zap.html                    
                    '''
                }
            }
        }
        post {
            always {
               archiveArtifacts artifacts: 'zap.html', fingerprint: true
            }

        success {
            discordSend description: "Zap Scan Stage", footer: "Zap Scan success", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
        }

        failure {
            discordSend description: "Zap Scan Stage", footer: "Zap scan failed", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "$DISCORD_WEBHOOK"
        }
        }
    }
 }

   options {
         preserveStashes()
         timestamps()
    }
}
