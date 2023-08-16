pipeline {
    agent any
    environment {
        IMAGE_NAME="lokeshb003/springboot-app:latest"
    }
    stages {
        stage('Checkout the GIT Repository') {
            steps {
                checkout([$class:'GitSCM',branches: [[name: '*/master']],userRemoteConfigs:[[url: 'https://github.com/lokeshb003/Springboot-app']]])
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
              sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=DevSecOps -Dsonar.projectName=DevSecOps -Dsonar.host.url=http://49.50.93.22:9000 -Dsonar.token=sqp_8a3fcd921faa873928c824ad9843b9e2afe7dbb1'
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
        stage('Deploy to Kubernetes') {
          steps {
            withKubeConfig(caCertificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKekNDQWcrZ0F3SUJBZ0lDQm5Vd0RRWUpLb1pJaHZjTkFRRUxCUUF3TXpFVk1CTUdBMVVFQ2hNTVJHbG4KYVhSaGJFOWpaV0Z1TVJvd0dBWURWUVFERXhGck9ITmhZWE1nUTJ4MWMzUmxjaUJEUVRBZUZ3MHlNekE0TVRZeApNRE13TXpoYUZ3MDBNekE0TVRZeE1ETXdNemhhTURNeEZUQVRCZ05WQkFvVERFUnBaMmwwWVd4UFkyVmhiakVhCk1CZ0dBMVVFQXhNUmF6aHpZV0Z6SUVOc2RYTjBaWElnUTBFd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUIKRHdBd2dnRUtBb0lCQVFEU0RMZm9UdkxMM3N3MTcyQ0pZWEx6Q2ZFVWFIT3YvMmt4V3ViWGxOK3hCVTdOTTgvUQpmVmRPL21pSWtndkVzN010RWFrTGNJYURkVFE4Tld5VDBIbWdobW0wSU5RTlhjY0tPWGJHcHB1QmQ3SHZwSjNsCnpnd2JkMVkrcHJZamJDbU5ULytLamhqY3VQMWFXYVNyQkw1blZ5R0hNbHVxQXMxZ3UxK213NDRnZmd1S1ZhVjYKa2txUzlmeHgzSG14WEZJMFc3Wk5GcnNzVnhNeHRicHZ1MExGbDZBZ2doSEFkMmdROFlwV2h6OVBlSkcwM1JtMApEVXc5bjRIYkJUQ0JtR3lOSjFnZ0NpclZsdFBnMkdZeEFmY2V2Mi9tT3ZvczFaVHA5eW9EaGZkRXBkS1czQnhBCmhJVTE4ZmNxYmQ5SnhZL2ZVT2ZCRXd6M3AwNDBUdEZyTjBpaEFnTUJBQUdqUlRCRE1BNEdBMVVkRHdFQi93UUUKQXdJQmhqQVNCZ05WSFJNQkFmOEVDREFHQVFIL0FnRUFNQjBHQTFVZERnUVdCQlRvc3AyNjBac0RXaG5MQllvNQp0VkpxL1dwZU16QU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFoRUUyZkdicXlwNmdMQ2N0RWxzYlRQMVFjTm5xCjdUUUNvWXVHMVRsZE1IWnY5ZHQrN2lDdDNFU2txSnh4VHc5SW9ZQ29lZ0VPV1gxK1FkbVBrYTVaUVFBTzRTSWEKSUVFUkxXMzlRK1dVcGpqOVdkckg1Y3IxVzZJSFBicDVsUmtuWFk2N211R1U4VHpnVVM3QVQ5WXNjbkFTM3IxQwpJamtwQSt2aTVKWVpjYlNoZ2tqZUZXWXpSU0wvSmZjN3dLa25KaEdVM1V5SnQ1RGozcm12UVM3ZVRwMWEvZ2ZuCmt0dXR6UDNGZVhSZnJrZHpVbzVTZTBjM1c3cFZUby9vUG1ITHAydXNwZVZDUGZORTZNc2lzVTRiditsd213UUQKcm9xZnMreTJ2djdSYUE0Zzh6blRpVzJucE9lQXZnVWdUbXkzQ3E2Tlo1TnlkQ3JMZzY2UVBKUkhYdz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K', clusterName: 'do-blr1-k8s-1-27-4-do-0-blr1-1692181779686', contextName: 'do-blr1-k8s-1-27-4-do-0-blr1-1692181779686', credentialsId: 'kubeconfig', namespace: 'default', restrictKubeConfigAccess: false, serverUrl: 'https://0895ebe7-ca34-4288-9d35-50bf8a5c76f9.k8s.ondigitalocean.com') {
                    sh 'kubectl apply -f kube-deployment.yaml'
                }
          }
        }
    }
}