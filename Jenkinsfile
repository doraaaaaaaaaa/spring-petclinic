pipeline {
    agent any
//STAGES PIPELINE2223
    tools { 
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        SONAR_HOST_URL = 'http://192.168.50.4:9000'
        SONAR_AUTH_TOKEN = credentials('sonar')
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

                    docker run --rm \
                      -v $(pwd):/scan \
                      zricethezav/gitleaks:latest \
                      detect --source=/scan \
                      --report-path=/scan/$REPORT \
                      --exit-code 1 || EXIT_CODE=$?

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
                echo '🔍 Scanning project with Trivy (FS)...'
                sh '''
                    docker run --rm -v $(pwd):/project aquasec/trivy fs \
                        --exit-code 1 \
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

        stage('Docker Build & Trivy Image Scan') {
            steps {
                echo '🐳 Build Docker image & scan with Trivy...'
                sh '''
                    docker build -t spring-petclinic:latest -f Dockerfile .

                    docker run --rm aquasec/trivy image \
                        --exit-code 1 \
                        --severity HIGH,CRITICAL \
                        spring-petclinic:latest
                '''
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
    }

    post {
        always {
            echo "🏁 Pipeline terminé!!!"
        }
    }
}
