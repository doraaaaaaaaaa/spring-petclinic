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
        script {
            echo "🔍 Running Gitleaks secret scan on the latest commit only..."
            
            // Supprime l'ancien rapport pour éviter faux positif
            sh 'rm -f gitleaks-report.json'

            // Scanner uniquement le dernier commit
            def status = sh(script: "gitleaks detect --source . --commit=HEAD --no-banner --exit-code=1 --report-path=gitleaks-report.json -v", returnStatus: true)
            
            if (status != 0) {
                echo "❌ Secrets detected in the latest commit! Check gitleaks-report.json for details."
                // Pour ne pas arrêter le pipeline, on commente la ligne error()
                 error("❌ Secrets detected by Gitleaks!")
            } else {
                echo "✅ No secrets found in the latest commit."
            }
        }
    }
}


        stage('Prepare Sonar') {
            steps {
                echo '🧹 Préparation du dossier pour SonarQube...'
                sh '''
                    mkdir -p $WORKSPACE/.sonar
                    echo "Dossier .sonar prêt : $WORKSPACE/.sonar"
                '''
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

        stage('Fix Permissions') {
            steps {
                echo '🔧 Correction des permissions sur le dossier target...'
                sh '''
                    mkdir -p target
                    chmod -R u+rwX target
                '''
            }
        }

        stage('Build Maven') {
            steps {
                echo '⚙️ Compilation du projet Maven...'
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
        success {
            echo "✅ Pipeline exécuté avec succès sans fuites de secrets."
        }
        failure {
            echo "🚨 Le pipeline a échoué — vérifie le rapport Gitleaks ou les logs Sonar/Maven."
        }
        always {
            echo "🏁 Pipeline terminé."
        }
    }
}
