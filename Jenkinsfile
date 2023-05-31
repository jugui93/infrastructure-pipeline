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
        withAWS(credentials: '70ba9347-f845-4a24-84ae-e9abb7b28bff') {
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        withAWS(credentials: '70ba9347-f845-4a24-84ae-e9abb7b28bff') {
          sh 'terraform plan'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        withAWS(credentials: '70ba9347-f845-4a24-84ae-e9abb7b28bff') {
          sh 'terraform apply --auto-approve'
        }
      }
    }

  }
}