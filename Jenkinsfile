pipeline {
 agent any

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
    }
    }

stage('Clair Scan') {
   steps {
       catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
           // Your commands here
           script {
               sh '''
                    sh 'docker compose up -d'
                    sh 'docker-compose exec clairctl clairctl report -l juicebox-log8100:${BUILD_ID}'
               '''
           }
       }
   }
   post {
       always {
          archiveArtifacts artifacts: 'clair.json', fingerprint: true
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
        }
    }
 }

   options {
         preserveStashes()
         timestamps()
    }
}
