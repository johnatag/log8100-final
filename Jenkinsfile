pipeline {
 agent any

 stages {
    stage('TFLint Scan') {
        steps {
            script {
               sh '''
                  docker run --rm -v $(pwd)/terraform:/data -t ghcr.io/terraform-linters/tflint /data
               '''
            }
        }
        post {
            always {
               archiveArtifacts artifacts: 'tflint.json', fingerprint: true
            }
        }
    }
    stage('Checkov Scan') {
        steps {
            script {
               sh '''
                  docker run --rm -v $(pwd)/terraform:/data bridgecrew/checkov -d /data
               '''
            }
        }
        post {
            always {
               archiveArtifacts artifacts: 'checkov.json', fingerprint: true
            }
        }
    }
    stage('Terrascan Scan') {
        steps {
            script {
               sh '''
                  docker run --rm -v $(pwd)/terraform:/data -t accuknox/terrascan:latest scan -i terraform -t /data
               '''
            }
        }
        post {
            always {
               archiveArtifacts artifacts: 'terrascan.json', fingerprint: true
            }
        }
    }
    stage('Terraform fmt') {
        steps {
            script {
               sh '''
                  docker run --rm -v $(pwd)/terraform:/data -w /data hashicorp/terraform:latest fmt > terraform.diff
               '''
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
                  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image your-dockerhub-username/juice-shop:${env.BUILD_ID} -o json > trivy.json
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
                  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock arminc/clair-local-scan:latest your-dockerhub-username/juice-shop:${env.BUILD_ID} > clair.json
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
                  docker run -t owasp/zap2docker-stable zap-baseline.py -t http://your-application-url -r zap.html
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
}
