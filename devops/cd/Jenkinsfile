pipeline {
  agent any

  parameters {
    string(name: 'DOCKERHUB_CREDENTIAL', defaultValue: 'dockerhub-token', description: 'Acceso de escritura a docker hub')
    booleanParam(name: 'UPLOAD', defaultValue: false, description: 'Upload hacia docker hub')
  }

  environment {
    ARTIFACT = "${env.BUILD_NUMBER}.zip"
  }

  stages {

    stage ("Repo") {
      steps {
        checkout scm
      }
    }

    stage ("Build") {
      steps {
        // TODO mejorar con script
        sh "zip -r ${env.ARTIFACT} src/"

        echo "${env.BUILD_NUMBER}"
        echo "${env.ARTIFACT}"
        sh "echo ${env.GIT_BRANCH}"
        
        sh "./docker-build.sh ${env.BUILD_NUMBER}"
      }
    }

    stage ("Test") {
      steps {
        parallel (
          unit: {
            echo "pruebas unitarias"
          },
          syntax: {
            echo "pruebas de sintaxis"
          },
          linter: {
            echo "flake8"
          }
        )
      }
    }

    stage ("Upload") {
      when {
        expression {
            return params.UPLOAD ==~ /(?i)(Y|YES|T|TRUE|ON|RUN)/
        }
      }
      steps {
        withCredentials([usernamePassword(credentialsId: "${params.DOCKERHUB_CREDENTIAL}", usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin"

          // TODO: mejorar con script
          sh "docker push mario21ic/dmc-api:${env.BUILD_NUMBER}"

          sh "docker logout"
        }
      }
    }

  }

  post {
    always {
      archiveArtifacts artifacts: "${ARTIFACT}", fingerprint: true, onlyIfSuccessful: true
      sh "rm -f ${ARTIFACT}"
      echo "Job has finished"
    }
  }

}
