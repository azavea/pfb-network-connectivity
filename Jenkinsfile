#!groovy
node {
  try {
    // Checkout the proper revision into the workspace.
    stage('checkout') {
      checkout scm
    }

    // Execute `setup` wrapped within a plugin that translates
    // ANSI color codes to something that renders inside the Jenkins
    // console.
    stage('setup') {
      wrap([$class: 'AnsiColorBuildWrapper']) {
        sh 'scripts/update'
      }
    }

    stage('cibuild') {
      wrap([$class: 'AnsiColorBuildWrapper']) {
        sh 'scripts/cibuild'
      }
    }
  } catch (err) {
    // Some exception was raised in the `try` block above. Assemble
    // an appropirate error message for Slack.

    def slackMessage = ":jenkins-angry: *pfb-network-connectivity (${env.BRANCH_NAME}) #${env.BUILD_NUMBER}*"
    if (env.CHANGE_TITLE) {
      slackMessage += "\n${env.CHANGE_TITLE} - ${env.CHANGE_AUTHOR}"
    }
    slackMessage += "\n<${env.BUILD_URL}|View Build>"
    slackSend color: 'danger', channel: '#pgw', message: slackMessage

    // Re-raise the exception so that the failure is propagated to
    // Jenkins.
    throw err
  } finally {
    // Pass or fail, ensure that the services and networks
    // created by Docker Compose are torn down.
    sh 'docker-compose down -v'
  }
}

