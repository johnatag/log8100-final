pipeline {
 agent any

 stages {
     stage('Build') {
         steps {
             script {
               dockerImage = docker.build("your-dockerhub-username/juice-shop:${env.BUILD_ID}")
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
 options {
   git(branch: 'main')
 }
}
