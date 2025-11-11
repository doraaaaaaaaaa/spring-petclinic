pipeline {
    agent any

    tools { 
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        SONAR_HOST_URL = 'http://192.168.50.4:9000'
    }

    stages {

        stage('Git Clone') {
            steps {
                echo '🔄 Clonage du dépôt Spring PetClinic...'
                git branch: 'test-gitleaks', url: 'https://github.com/doraaaaaaaaaa/spring-petclinic.git'
            }
        }

        stage('Secret Scan') {
            steps {
                echo '🔒 Running Gitleaks Secret Scan...'
                sh '''
                    echo "📁 Contenu du projet :"
                    ls -la
                    echo "🚨 Début scan Gitleaks"
                    gitleaks detect \
                        --source . \
                        --no-banner \
                        --exit-code=1 \
                        --report-path gitleaks-report.json \
                        -v
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true
                }
                success {
                    echo "✅ Aucun secret détecté — OK ! ✅"
                }
                failure {
                    echo "❌ Secret détecté — Pipeline échoué ❌"
                    error("❌ Pipeline arrêté à cause d'un secret détecté ❌")
                }
            }
        }

        stage('Prepare Sonar') {
            steps {
                echo '🧹 Préparation du dossier pour SonarQube...'
                sh 'mkdir -p target/sonar && sudo chown -R jenkins:jenkins target'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '🔍 Analyse du code avec SonarQube...'
                withCredentials([string(credentialsId: 'sonar', variable: 'SONAR_AUTH_TOKEN')]) {
                    sh """
                        mvn sonar:sonar \
                            -Dsonar.projectKey=spring-petclinic \
                            -Dsonar.host.url=${SONAR_HOST_URL} \
                            -Dsonar.login=$SONAR_AUTH_TOKEN \
                            -Dsonar.working.directory=$WORKSPACE/.sonar
                    """
                }
            }
        }

        stage('Build Maven') {
            steps {
                echo '⚙️ Compilation du projet...'
                sh 'mvn clean package -DskipTests=true'
            }
        }

        stage('Run Tests') {
            steps {
                echo '🧪 Exécution des tests unitaires...'
                sh 'mvn test'
            }
        }

    }

    post {
        always {
            echo "🏁 Pipeline terminé"
        }
    }
}
