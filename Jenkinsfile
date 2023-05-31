pipeline {
  agent any
  tool name: 'terraform', type: 'terraform'
  stages {
    stage('Checkout') {
      steps {
        git(url: 'git@github.com:jugui93/infrastructure-pipeline.git', branch: 'main', credentialsId: 'c3901aa1-c7bc-42f7-819e-3cc7219596d7')
      }
    }

    stage('Terraform Init') {
      steps {
        withCredentials([<object of type com.cloudbees.jenkins.plugins.awscredentials.AmazonWebServicesCredentialsBinding>]) {
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        withCredentials([<object of type com.cloudbees.jenkins.plugins.awscredentials.AmazonWebServicesCredentialsBinding>]) {
          sh 'terraform plan'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        withCredentials([<object of type com.cloudbees.jenkins.plugins.awscredentials.AmazonWebServicesCredentialsBinding>]) {
          sh 'terraform apply --auto-approve'
        }
      }
    }

  }
}