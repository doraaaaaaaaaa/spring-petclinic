pipeline {
    agent any

    environment {
        SONAR_HOST_URL = 'http://192.168.50.4:9000'
        SONAR_AUTH_TOKEN = credentials('sonar')
        DOCKER_IMAGE = 'spring-petclinic:latest'
        JAVA_DOCKER_IMAGE = 'eclipse-temurin:25-jdk'
    }

    stages {

        stage('Git Clone') {
            steps {
                echo '🔄 Clonage du dépôt Spring PetClinic...'
                git branch: 'test/gitleaks-secret', url: 'https://github.com/doraaaaaaaaaa/spring-petclinic.git'
            }
        }

        stage('Debug Workspace') {
            steps {
                echo '🗂 Contenu du workspace :'
                sh 'ls -R'
            }
        }

        stage('Secret Scan - Gitleaks') {
            steps {
                echo "🔒 Scanning with Gitleaks..."
                sh '''
                    REPORT=gitleaks-report.json
                    docker run --rm -v $(pwd):/scan zricethezav/gitleaks:latest detect \
                        --source=/scan \
                        --report-path=/scan/$REPORT || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true
                }
            }
        }

        stage('Trivy FS Scan') {
            steps {
                echo '🔍 Scanning source files with Trivy...'
                sh '''
                    mkdir -p /tmp/trivy-cache
                    docker run --rm -v $(pwd):/project -v /tmp/trivy-cache:/root/.cache/trivy aquasec/trivy fs \
                        --exit-code 0 \
                        --severity HIGH,CRITICAL \
                        --format json \
                        --output /project/trivy-report.json \
                        /project
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
                }
            }
        }

        stage('Build Maven (Java 25)') {
            agent {
                docker {
                    image 'maven:3.9.9-eclipse-temurin-25'
                    args '-v /root/.m2:/root/.m2'
                }
            }
            steps {
                echo '⚙️ Compilation du projet avec Maven (Java 25)...'
                sh 'mvn clean package -DskipTests'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: false
                }
            }
        }

        stage('SonarQube Analysis (Java 25)') {
            agent {
                docker {
                    image 'maven:3.9.9-eclipse-temurin-25'
                    args '-v /root/.m2:/root/.m2'
                }
            }
            steps {
                echo '🔍 Analyse du code avec SonarQube...'
                sh """
                    mvn sonar:sonar \
                        -Dsonar.projectKey=spring-petclinic \
                        -Dsonar.host.url=${SONAR_HOST_URL} \
                        -Dsonar.login=${SONAR_AUTH_TOKEN}
                """
            }
        }

        stage('Docker Build & Trivy Image Scan') {
            steps {
                echo '🐳 Build Docker image avec Java 25 et scan...'
                sh '''
                    docker build -t ${DOCKER_IMAGE} -f Dockerfile .
                    mkdir -p /tmp/trivy-cache
                    docker run --rm -v /tmp/trivy-cache:/root/.cache/trivy aquasec/trivy image \
                        --exit-code 0 \
                        --severity HIGH,CRITICAL \
                        --format json \
                        --output trivy-image-report.json \
                        ${DOCKER_IMAGE}
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-image-report.json', allowEmptyArchive: true
                }
            }
        }
    }

    post {
        always {
            echo "🏁 Pipeline terminé 🚀"
        }
    }
}
