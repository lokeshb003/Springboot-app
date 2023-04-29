pipeline {
    agent any
    environment {
        IMAGE_NAME="lokeshb003/springboot-app:latest"
    }
    stages {
        stage('Checkout the GIT Repository') {
            steps {
                checkout([$class:'GitSCM',branches: [[name: '*/main']],userRemoteConfigs:[[url: 'https://github.com/lokeshb003/Springboot-app']]])
            }
        }
        stage('Build the SpringBoot Application') {
            steps {
                sh 'mvn clean package -DskipTests=true'
            }
        }
        stage('Test the Springboot Application') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                    jacoco(execPattern: '**/build/jacoco/*.exec',classPattern: '**/build/classes/java/main',sourcePattern: '**/src/main')
                }
            }
        }
        stage('Mutation Testing') {
          steps {
            sh 'mvn org.pitest:pitest-maven:mutationCoverage'
          }
          post {
            always {
              pitmutation killRatioMustImprove: false, minimumKillRatio: 50.0, mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
            }
          }
        }
        stage('SonarQube SAST Test') {
            steps {
               sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=project-ci-cd -Dsonar.host.url=https://sonar.melospiza.in -Dsonar.login=sqp_18d354cb569562ace17859671a35783986a3e520'

               withSonarQubeEnv('sonar') {
                 waitForQualityGate abortPipeline: true
               }
            }
        }
        stage('Build Docker Image') {
            steps {
              sh 'docker build -t ${IMAGE_NAME} .'
              sh 'docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}'
              sh 'docker push ${IMAGE_NAME}'
            }
        }
        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image ${IMAGE_NAME}'
            }
        }
    }
}
