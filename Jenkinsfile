#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2-rhel-ee-large' }

  options {
    timestamps()
    buildDiscarder(logRotator(daysToKeepStr: '30'))
  }

  stages {
    stage('Test') {
      steps {
        sh './test.sh'

        junit 'spec/reports/*.xml'
        cobertura coberturaReportFile: 'spec/coverage/coverage.xml'
        sh 'cp spec/coverage/coverage.xml cobertura.xml'
        ccCoverage("cobertura", "github.com/cyberark/slosilo")
      }
    }

    stage('Publish to RubyGems') {
      agent { label 'executor-v2' }
      when {
        allOf {
          branch 'master'
          expression {
            boolean publish = false

            try {
              timeout(time: 5, unit: 'MINUTES') {
                input(message: 'Publish to RubyGems?')
                publish = true
              }
            } catch (final ignore) {
              publish = false
            }

            return publish
          }
        }
      }

      steps {
        checkout scm
        sh './publish-rubygem.sh'
        deleteDir()
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}
