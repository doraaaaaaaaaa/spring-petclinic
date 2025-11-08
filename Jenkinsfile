pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        SONAR_HOST_URL = 'http://192.168.50.4:9000'
        SONAR_AUTH_TOKEN = credentials('sonar')
        DOCKER_REGISTRY = '192.168.50.4:5000'
        IMAGE_NAME = 'petclinic'
    }

    stages {

        stage('Git Clone') {
            steps {
                echo '🔄 Clonage du dépôt Spring PetClinic...'
                git branch: 'main', url: 'https://github.com/spring-projects/spring-petclinic.git'
            }
        }

        stage('Maven Build') {
            steps {
                echo '⚙️ Compilation du projet avec Maven...'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Tests Unitaires') {
            steps {
                echo '🧪 Exécution des tests unitaires...'
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Analyse SonarQube') {
            steps {
                echo '🔍 Analyse du code avec SonarQube...'
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=petclinic'
                }
            }
        }

        stage('Scan Gitleaks - Secret Detection') {
            steps {
                echo '🕵️‍♂️ Scan des secrets avec Gitleaks...'
                sh '''
                docker run --rm -v $(pwd):/path zricethezav/gitleaks:latest detect --source="/path" --verbose --no-git --redact
                '''
            }
        }

        stage('Scan Trivy - Image SCA') {
            steps {
                echo '🧰 Scan de sécurité avec Trivy...'
                sh '''
                docker build -t ${IMAGE_NAME}:latest .
                docker run --rm aquasec/trivy image --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Docker Build & Push') {
            steps {
                echo '🐳 Construction et envoi de l’image vers le registre Nexus...'
                sh '''
                docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest .
                docker login ${DOCKER_REGISTRY} -u admin -p admin123
                docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Déploiement') {
            steps {
                echo '🚀 Déploiement du conteneur...'
                sh '''
                docker stop petclinic || true && docker rm petclinic || true
                docker run -d -p 8080:8080 --name petclinic ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
                '''
            }
        }

    }

    post {
        success {
            echo '✅ Pipeline exécuté avec succès !'
        }
        failure {
            echo '❌ Échec du pipeline, veuillez vérifier les logs.'
        }
    }
}
