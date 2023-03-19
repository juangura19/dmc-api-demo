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
          sh "docker push francisjosue/dmc-api:${env.BUILD_NUMBER}"

          sh "docker logout"
        }
      }
    }

    stage ("Deploy") {
      steps {
        script {
          try {
            def IMAGE_TAG = env.BUILD_NUMBER
            sh "docker stop dmc-api"
            sh "docker rm dmc-api"
            sh "docker run -d -p 8080:8080 --name dmc-api francisjosue/dmc-api:${IMAGE_TAG}"
            sh "docker ps | grep dmc-api"
            echo "Deployment completed successfully"
          } catch (Exception e) {
            echo "Deployment failed"
            currentBuild.result = 'FAILURE'
            error(e)
          }
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
