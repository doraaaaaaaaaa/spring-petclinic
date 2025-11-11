pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME_21' // Jenkins utilise Java 21 pour sa compatibilité
    }

    environment {
        SONAR_HOST_URL = 'http://192.168.50.4:9000'
        SONAR_AUTH_TOKEN = credentials('sonar')
        DOCKER_IMAGE = 'spring-petclinic:latest'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/doraaaaaaaaaa/spring-petclinic.git'
            }
        }

        stage('Build Maven') {
            steps {
                echo '⚙️ Build du projet avec Maven (Java 21)...'
                sh '''
                    docker run --rm -v $(pwd):/app -w /app maven:3.9.9-eclipse-temurin-21 \
                        mvn clean package -DskipTests
                '''
                echo "✅ Maven build terminé, le JAR doit être dans target/"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '🔍 Analyse SonarQube...'
                sh '''
                    docker run --rm -v $(pwd):/app -w /app \
                        -e SONAR_HOST_URL=$SONAR_HOST_URL \
                        -e SONAR_TOKEN=$SONAR_AUTH_TOKEN \
                        maven:3.9.9-eclipse-temurin-21 \
                        mvn sonar:sonar -Dsonar.projectKey=spring-petclinic
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Construction de l’image Docker Java 25...'
                sh '''
                    docker build -t $DOCKER_IMAGE .
                '''
            }
        }

        stage('Run Container') {
            steps {
                echo '🚀 Lancement du conteneur...'
                sh '''
                    docker stop spring-petclinic || true
                    docker rm spring-petclinic || true
                    docker run -d --name spring-petclinic -p 8080:8080 $DOCKER_IMAGE
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline terminé avec succès !'
        }
        failure {
            echo '❌ Échec du pipeline.'
        }
    }
}
