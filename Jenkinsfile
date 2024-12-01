pipeline {
    agent any

    environment {
        DOCKER_COMPOSE_DIR = 'docker' // Відносний шлях до папки з docker-compose.yml
    }

    stages {
        stage('Docker Compose Up') {
            steps {
                script {
                    dir(DOCKER_COMPOSE_DIR) {
                        sh 'docker-compose up -d'
                    }
                }
            }
        }

        stage('Wait for Services') {
            steps {
                script {
                    sh 'sleep 30'
                }
            }
        }
    }

    post {
        always {
            script {
                dir(DOCKER_COMPOSE_DIR) {
                    sh 'docker-compose ps'
                }
            }
        }
        failure {
            echo 'Pipeline failed!'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
    }
}
