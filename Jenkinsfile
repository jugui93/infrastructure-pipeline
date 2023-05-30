pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        git(url: 'git@github.com:jugui93/infrastructure-pipeline.git', branch: 'main', credentialsId: 'c3901aa1-c7bc-42f7-819e-3cc7219596d7')
      }
    }

    stage('Terraform Init') {
      steps {
        sh '''terraform init
'''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh 'terraform plan'
      }
    }

    stage('Terraform Apply') {
      steps {
        sh 'terraform apply --auto-approve'
      }
    }

  }
}