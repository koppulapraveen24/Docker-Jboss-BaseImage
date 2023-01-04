pipeline {

  agent none  
  
  options {
      timeout(time: 15, unit: 'MINUTES')
  }

  parameters {
     string(name: 'ECRURL', defaultValue: 'https://437030480074.dkr.ecr.ap-south-1.amazonaws.com', description: 'Please Enter your Docker ECR REGISTRY URL?')
     string(name: 'REPO', defaultValue: 'wezvabaseimage', description: 'Please Enter your Docker Repo Name?')
     string(name: 'REGION', defaultValue: 'ap-south-1', description: 'Please Enter your AWS Region?')
  }

 stages  {
  stage('Checkout')
  {
   agent { label 'demo' }
   steps { 
    git credentialsId: 'GitlabCred', url: 'https://gitlab.com/wezvatechprojects/demo.git'
   }
  }
  
  stage('Build Image') 
  {
    agent { label 'demo' }
    steps{
      script {
	      //Prepare the Tag name for the Image
	      dockerTag = params.REPO + ":" + env.BUILD_ID
		  
          docker.withRegistry( params.ECRURL, 'ecr:ap-south-1:AWSCred' ) {
             /* Build Docker Image locally */
             myImage = docker.build(dockerTag)

             /* Push the Image to the Registry */
             myImage.push()
          }
      }
    }
    post {
     always {
	  sh "docker rmi ${params.REPO}:${env.BUILD_ID}"
	   }
    }
  }
  
 }
}
