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
   }
}
