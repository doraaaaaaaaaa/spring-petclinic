pipeline {
    agent any
tools {
    maven 'M2_HOME'
    jdk 'JAVA_HOME_25'
}

    environment {
        SONAR_HOST_URL = 'http://192.168.50.4:9000'
        SONAR_AUTH_TOKEN = credentials('sonar')
        DOCKER_IMAGE = 'spring-petclinic:latest'
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
                echo "🔒 Running Gitleaks Secret Scan..."
                sh '''
                    REPORT=gitleaks-report.json
                    rm -f $REPORT || true
                    EXIT_CODE=0

                    docker run --rm -v $(pwd):/scan zricethezav/gitleaks:latest detect \
                        --source=/scan \
                        --report-path=/scan/$REPORT || EXIT_CODE=$?

                    echo "🔚 Gitleaks exit code: $EXIT_CODE"
                    exit $EXIT_CODE
                '''
            }
            post {
                always {
                    echo "📄 Gitleaks Report Content:"
                    sh "cat gitleaks-report.json 2>/dev/null || echo '⚠️ No report file generated!'"
                    archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true
                }
                failure {
                    echo "❌ SECRET DETECTÉ — PIPELINE STOPPÉ ❌"
                }
            }
        }

        stage('Trivy FS Scan') {
            steps {
                echo '🔍 Scanning project files with Trivy...'
                sh '''
                    mkdir -p /tmp/trivy-cache
                    docker run --rm -v $(pwd):/project -v /tmp/trivy-cache:/root/.cache/trivy aquasec/trivy fs \
                        --exit-code 1 \
                        --severity HIGH,CRITICAL \
                        --format json \
                        --timeout 10m \
                        --output /project/trivy-report.json \
                        /project || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
                }
            }
        }

        stage('Build Maven') {
            steps {
                echo '⚙️ Compilation du projet Maven...'
                sh 'mvn clean package -DskipTests'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: false
                }
            }
        }

        stage('SonarQube Analysis') {
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
                echo '🐳 Build Docker image à partir du JAR et scan...'
                sh '''
                    docker build -t ${DOCKER_IMAGE} -f Dockerfile .
                    mkdir -p /tmp/trivy-cache
                    docker run --rm -v /tmp/trivy-cache:/root/.cache/trivy aquasec/trivy image \
                        --exit-code 1 \
                        --severity HIGH,CRITICAL \
                        --timeout 10m \
                        ${DOCKER_IMAGE} || true
                '''
            }
        }
    }

    post {
        always {
            echo "🏁 Pipeline terminé avec succès 🚀"
        }
    }
}
