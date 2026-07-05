pipeline {
    agent any

    options {
        // Garde les 10 derniers builds, et coupe un build bloque apres 30 min.
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {

        stage('Checkout') {
            steps {
                // En Multibranch Pipeline, "checkout scm" recupere AUTOMATIQUEMENT
                // la bonne branche (main, dev, feature/...) detectee par Jenkins.
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn -B clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn -B test'
            }
            post {
                always {
                    // Publie le rapport JUnit (visible dans Blue Ocean -> onglet Tests)
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package') {
            steps {
                sh 'mvn -B package -DskipTests'
                // Archive le JAR : telechargeable depuis la page du build / Blue Ocean
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Analyse (facultatif)') {
            steps {
                // Analyse statique Checkstyle. catchError : une alerte de style
                // ne doit pas faire echouer tout le pipeline.
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh 'mvn -B checkstyle:checkstyle'
                    publishHTML(target: [
                        reportDir: 'target/site',
                        reportFiles: 'checkstyle.html',
                        reportName: 'Checkstyle',
                        keepAll: true,
                        allowMissing: true,
                        alwaysLinkToLastBuild: true
                    ])
                }
            }
        }
    }

    post {
        success { echo 'Pipeline termine avec succes.' }
        failure { echo 'Echec du pipeline : consultez les logs de l etape en rouge.' }
    }
}
