pipeline {
 agent any

 stages {

    stage('Stash Terraform code') {
        steps {
            git 'https://github.com/johnatag/log8100-final.git'
            stash includes: 'terraform/**', name: 'my-terraform-code'
        }
    }

    stage('TFLint scan') {
        steps {
            script {
                docker.image('ghcr.io/terraform-linters/tflint:latest').inside("--entrypoint=''") {
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
        post {
            always {
               archiveArtifacts artifacts: 'tflint.xml', fingerprint: true
            }
        }
    }

    stage('Checkov scan') {
        steps {
            script {
                docker.image('bridgecrew/checkov:latest').inside("--entrypoint=''") {
                    unstash 'my-terraform-code'
                    try {
                        sh 'checkov -d . --use-enforcement-rules -o cli -o junitxml --output-file-path console,checkov_scan.xml --repo-id johnatag/log8100-final --branch main'
                        junit skipPublishingChecks: true, testResults: 'checkov_scan.xml'
                    } catch (err) {
                        junit skipPublishingChecks: true, testResults: 'checkov_scan.xml'
                        throw err
                    }
                }
            }
        }
        post {
            always {
                archiveArtifacts artifacts: 'checkov_scan.xml', fingerprint: true
            }
        }
    }


    stage('Terrascan scan') {
        steps {
            script {
                docker.image('accuknox/terrascan:latest').inside("--entrypoint=''") {
                    unstash 'my-terraform-code'
                    try {
                        sh 'terrascan scan -t terraform -d . -o junitxml -o console -i terraform -r terrascan.xml'
                        junit skipPublishingChecks: true, testResults: 'terrascan.xml'
                    } catch (err) {
                        junit skipPublishingChecks: true, testResults: 'terrascan.xml'
                        throw err
                    }
                }
            }
        }
        post {
            always {
                archiveArtifacts artifacts: 'terrascan.xml', fingerprint: true
            }
        }
    }

    stage('Terraform fmt') {
        steps {
            script {
                docker.image('hashicorp/terraform:latest').inside("--entrypoint=''") {
                    unstash 'my-terraform-code'
                    sh 'terraform fmt -chdir=/data -diff > terraform.diff'
                }
            }
        }
        post {
            always {
                archiveArtifacts artifacts: 'terraform.diff', fingerprint: true
            }
        }
    }

    stage('Build') {
        steps {
            script {
              dockerImage = docker.build("floatdocka/juicebox-log8100:${env.BUILD_ID}")
            }
        }
    }

    stage('Push') {
        steps {
            script {
              docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                dockerImage.push()
                dockerImage.push("latest")
              }
            }
        }
    }

    stage('Trivy Scan') {
        steps {
            script {
               sh '''
                  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image floatdocka/juicebox-log8100:${env.BUILD_ID} -o json > trivy.json
               '''
            }
        }
        post {
            always {
               archiveArtifacts artifacts: 'trivy.json', fingerprint: true
            }
        }
    }

    stage('Clair Scan') {
        steps {
            script {
               sh '''
                  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock arminc/clair-local-scan:latest floatdocka/juicebox-log8100:${env.BUILD_ID} > clair.json
               '''
            }
        }
        post {
            always {
               archiveArtifacts artifacts: 'clair.json', fingerprint: true
            }
        }
    }

    stage('ZAP Scan') {
        steps {
            script {
               sh '''
                  docker run -t owasp/zap2docker-stable zap-baseline.py -t https://demo.owasp-juice.shop/ -r zap.html
               '''
            }
        }
        post {
            always {
               archiveArtifacts artifacts: 'zap.html', fingerprint: true
            }
        }
    }
 }

   options {
         preserveStashes()
         timestamps()
    }
}
