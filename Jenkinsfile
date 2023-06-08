pipeline {
  agent {
    label 'ubuntu'
  }
  tools {
    terraform 'terraform'
  }
  parameters {
    choice choices: ['apply', 'destroy'], description: 'Action to be taken on the Terraform configuration', name: 'action'
  }
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

    stage('Terraform action') {
      steps {
        withAWS(credentials: '70ba9347-f845-4a24-84ae-e9abb7b28bff') {
          sh 'terraform ${action} --auto-approve'
        }
      }
    }

  }
}