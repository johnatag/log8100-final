pipeline {
 agent any

 stages {
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

    stage('Clair Scan') {
        steps {
            script {
                sh '''
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock arminc/clair-local-scan:latest floatdocka/juicebox-log8100:${env.BUILD_ID}
                '''
            }
        }
    }

    stage('Trivy Scan') {
        steps {
            script {
                sh '''
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image floatdocka/juicebox-log8100:${env.BUILD_ID}
                '''
            }
        }
    }

    stage('ZAP Scan') {
        steps {
            script {
                sh '''
                    docker run -t owasp/zap2docker-stable zap-baseline.py -t https://demo.owasp-juice.shop
                '''
            }
        }
    }

 }
}
