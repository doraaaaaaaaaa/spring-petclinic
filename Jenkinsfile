pipeline {
    agent any

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
                git branch: 'test-gitleaks', url: 'https://github.com/doraaaaaaaaaa/spring-petclinic.git'
            }
        }

        stage('Secret Scan') {
            steps {
                echo '🔒 Running Gitleaks Secret Scan...'
                sh '''
                    mkdir -p jenkins_temp_scan
                    cd jenkins_temp_scan
                    gitleaks detect \
                        --source ../ \
                        --no-banner \
                        --exit-code=1 \
                        --report-path ../gitleaks-report.json \
                        -v
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true
                }
            }
        }

        stage('Prepare Build') {
            steps {
                echo '🧹 Préparation du build dans un dossier temporaire...'
                sh '''
                    mkdir -p build_target
                '''
            }
        }

        stage('Build Maven') {
            steps {
                echo '⚙️ Compilation du projet...'
                sh 'mvn -f pom.xml clean package -DskipTests=true -DoutputDirectory=build_target'
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
