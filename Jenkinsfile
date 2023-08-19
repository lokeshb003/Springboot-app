pipeline {
    agent any
    environment {
        IMAGE_NAME="lokeshb003/springboot-app:latest"
        applicationURL="159.89.220.179"
        applicationURI="increment/99"
        deployment_name="springboot-app-deployment"
        serviceName="springboot-app-service"
    }
    stages {
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
              sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=DevSecOps -Dsonar.projectName=DevSecOps -Dsonar.host.url=http://143.198.226.169:9000 -Dsonar.token=sqp_14e8379af2088c14029903180a4fcc4dc25b3e27'
            }
        }
        
        stage('Build Docker Image') {
            steps {
              sh 'docker build -t ${IMAGE_NAME} .'
              sh 'docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}'
              sh 'docker push ${IMAGE_NAME}'
            }
        }
        stage('Trivy Image Scan') {
            steps {
                sh 'docker run --rm aquasec/trivy image ${IMAGE_NAME}'
            }
        }
        stage('Deploy to Kubernetes') {
          steps {
            withKubeConfig(caCertificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKekNDQWcrZ0F3SUJBZ0lDQm5Vd0RRWUpLb1pJaHZjTkFRRUxCUUF3TXpFVk1CTUdBMVVFQ2hNTVJHbG4KYVhSaGJFOWpaV0Z1TVJvd0dBWURWUVFERXhGck9ITmhZWE1nUTJ4MWMzUmxjaUJEUVRBZUZ3MHlNekE0TVRZeApNVFV4TlRkYUZ3MDBNekE0TVRZeE1UVXhOVGRhTURNeEZUQVRCZ05WQkFvVERFUnBaMmwwWVd4UFkyVmhiakVhCk1CZ0dBMVVFQXhNUmF6aHpZV0Z6SUVOc2RYTjBaWElnUTBFd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUIKRHdBd2dnRUtBb0lCQVFDbUhuYjM4dzNWblYyTmduQ1RjQ2lycU9ZY0psdGRkbzNhS3RVN1VxRjVWTmFObWNSMgorQ295cUpSS2xPMHpuMU5FUnZTZWpnRU91VVVyRjFCeGw1VmVzVUI5K2Q1Q3IwdGVZSGpjRzAwY3RCQUJCbnBXCmlhZTJsNDkxQkpyOWEvZE9pSE1wS1BKakVVVE1SZlhtV2U1Z3RQeDRyemVjTEFhSFNqbnJ1a0paeG5zNWRrREcKTUdrbnVpR296STd6V3FuUit5SjE0VmdoWlYwK1IwQUVHYlhIVGlJaEVtR1NlcUZ3YS9CS3FkQWY3RTl3a2FyZwp4WUNWSGM2NVA1dUFxNVAxU0tGMUo5Z29pdW5iTjRvU2JuNlgzY1pMeXdORGhwSUZEMUo0Y1BZYkt5N29zQTVjCkxaNG9kVDh4cWpoNG0xK3hiQ3AwcUthQUM4Wmo1RTI1dDFzekFnTUJBQUdqUlRCRE1BNEdBMVVkRHdFQi93UUUKQXdJQmhqQVNCZ05WSFJNQkFmOEVDREFHQVFIL0FnRUFNQjBHQTFVZERnUVdCQlJJTGpLcDNoczFBZ1hGcFZBVApTODB1WlZyeVNUQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFNeGVZQVRJQnlQci9hWFBBL3Y2QW9YUjZoL0RECmRIZWhjbm8wblYzbkZJbGZsVUtxWTJJSWYwM2NuT2tTZ0RzdFNYaVFlanpncVdiU0djd3BtQnhSdHBESzViK0kKTXdiYkFLai9HV0ZIK0xaUXFQK0xiditEaDEvTXRxeE4xZDlrR0dJUHltK2doM3VXNVlUOGVKSGRCY1A0c3hHdQpKR1JHVWtIRjRDaWtTRTI3U2luZkZ3N3pHZWs2OHU2aE1uUEhCVUFLay9WcVR4Tk9VMTFEUTNQYi9GQ2NxcHBvCmpQakJRY3ZkYkVyeXFpajJmcDJoMlNWenR0Q2VUbmthTFM2Z3JTN1BnTzRQQjVDbmdVVU9kckJzdEF1NElyYWYKVUpTNzRpM0ZjMEVUSHpZNG03SHdURWVOWS9rUWR4NXBIaExVUllZVUsvcGgwWFFJV2VYSlRGMlgwQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K', clusterName: 'do-sfo2-k8s-1-27-4-do-0-sfo2-1692186680734', contextName: 'do-sfo2-k8s-1-27-4-do-0-sfo2-1692186680734', credentialsId: 'kubeconfig', namespace: 'default', restrictKubeConfigAccess: false, serverUrl: 'https://bff11845-04ad-4323-9d2b-e03ec8425a3f.k8s.ondigitalocean.com') {
                    sh 'kubectl apply -f kube-deployment.yaml'
                }
          }
        }
        stage('Integration Test with cURL') {
          steps {
            script {
              try {
                withKubeConfig(caCertificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKekNDQWcrZ0F3SUJBZ0lDQm5Vd0RRWUpLb1pJaHZjTkFRRUxCUUF3TXpFVk1CTUdBMVVFQ2hNTVJHbG4KYVhSaGJFOWpaV0Z1TVJvd0dBWURWUVFERXhGck9ITmhZWE1nUTJ4MWMzUmxjaUJEUVRBZUZ3MHlNekE0TVRZeApNVFV4TlRkYUZ3MDBNekE0TVRZeE1UVXhOVGRhTURNeEZUQVRCZ05WQkFvVERFUnBaMmwwWVd4UFkyVmhiakVhCk1CZ0dBMVVFQXhNUmF6aHpZV0Z6SUVOc2RYTjBaWElnUTBFd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUIKRHdBd2dnRUtBb0lCQVFDbUhuYjM4dzNWblYyTmduQ1RjQ2lycU9ZY0psdGRkbzNhS3RVN1VxRjVWTmFObWNSMgorQ295cUpSS2xPMHpuMU5FUnZTZWpnRU91VVVyRjFCeGw1VmVzVUI5K2Q1Q3IwdGVZSGpjRzAwY3RCQUJCbnBXCmlhZTJsNDkxQkpyOWEvZE9pSE1wS1BKakVVVE1SZlhtV2U1Z3RQeDRyemVjTEFhSFNqbnJ1a0paeG5zNWRrREcKTUdrbnVpR296STd6V3FuUit5SjE0VmdoWlYwK1IwQUVHYlhIVGlJaEVtR1NlcUZ3YS9CS3FkQWY3RTl3a2FyZwp4WUNWSGM2NVA1dUFxNVAxU0tGMUo5Z29pdW5iTjRvU2JuNlgzY1pMeXdORGhwSUZEMUo0Y1BZYkt5N29zQTVjCkxaNG9kVDh4cWpoNG0xK3hiQ3AwcUthQUM4Wmo1RTI1dDFzekFnTUJBQUdqUlRCRE1BNEdBMVVkRHdFQi93UUUKQXdJQmhqQVNCZ05WSFJNQkFmOEVDREFHQVFIL0FnRUFNQjBHQTFVZERnUVdCQlJJTGpLcDNoczFBZ1hGcFZBVApTODB1WlZyeVNUQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFNeGVZQVRJQnlQci9hWFBBL3Y2QW9YUjZoL0RECmRIZWhjbm8wblYzbkZJbGZsVUtxWTJJSWYwM2NuT2tTZ0RzdFNYaVFlanpncVdiU0djd3BtQnhSdHBESzViK0kKTXdiYkFLai9HV0ZIK0xaUXFQK0xiditEaDEvTXRxeE4xZDlrR0dJUHltK2doM3VXNVlUOGVKSGRCY1A0c3hHdQpKR1JHVWtIRjRDaWtTRTI3U2luZkZ3N3pHZWs2OHU2aE1uUEhCVUFLay9WcVR4Tk9VMTFEUTNQYi9GQ2NxcHBvCmpQakJRY3ZkYkVyeXFpajJmcDJoMlNWenR0Q2VUbmthTFM2Z3JTN1BnTzRQQjVDbmdVVU9kckJzdEF1NElyYWYKVUpTNzRpM0ZjMEVUSHpZNG03SHdURWVOWS9rUWR4NXBIaExVUllZVUsvcGgwWFFJV2VYSlRGMlgwQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K', clusterName: 'do-sfo2-k8s-1-27-4-do-0-sfo2-1692186680734', contextName: 'do-sfo2-k8s-1-27-4-do-0-sfo2-1692186680734', credentialsId: 'kubeconfig', namespace: 'default', restrictKubeConfigAccess: false, serverUrl: 'https://bff11845-04ad-4323-9d2b-e03ec8425a3f.k8s.ondigitalocean.com') {
                    sh 'bash integration-test.sh'
                }
              }
              catch (e) {
                withKubeConfig(caCertificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKekNDQWcrZ0F3SUJBZ0lDQm5Vd0RRWUpLb1pJaHZjTkFRRUxCUUF3TXpFVk1CTUdBMVVFQ2hNTVJHbG4KYVhSaGJFOWpaV0Z1TVJvd0dBWURWUVFERXhGck9ITmhZWE1nUTJ4MWMzUmxjaUJEUVRBZUZ3MHlNekE0TVRZeApNVFV4TlRkYUZ3MDBNekE0TVRZeE1UVXhOVGRhTURNeEZUQVRCZ05WQkFvVERFUnBaMmwwWVd4UFkyVmhiakVhCk1CZ0dBMVVFQXhNUmF6aHpZV0Z6SUVOc2RYTjBaWElnUTBFd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUIKRHdBd2dnRUtBb0lCQVFDbUhuYjM4dzNWblYyTmduQ1RjQ2lycU9ZY0psdGRkbzNhS3RVN1VxRjVWTmFObWNSMgorQ295cUpSS2xPMHpuMU5FUnZTZWpnRU91VVVyRjFCeGw1VmVzVUI5K2Q1Q3IwdGVZSGpjRzAwY3RCQUJCbnBXCmlhZTJsNDkxQkpyOWEvZE9pSE1wS1BKakVVVE1SZlhtV2U1Z3RQeDRyemVjTEFhSFNqbnJ1a0paeG5zNWRrREcKTUdrbnVpR296STd6V3FuUit5SjE0VmdoWlYwK1IwQUVHYlhIVGlJaEVtR1NlcUZ3YS9CS3FkQWY3RTl3a2FyZwp4WUNWSGM2NVA1dUFxNVAxU0tGMUo5Z29pdW5iTjRvU2JuNlgzY1pMeXdORGhwSUZEMUo0Y1BZYkt5N29zQTVjCkxaNG9kVDh4cWpoNG0xK3hiQ3AwcUthQUM4Wmo1RTI1dDFzekFnTUJBQUdqUlRCRE1BNEdBMVVkRHdFQi93UUUKQXdJQmhqQVNCZ05WSFJNQkFmOEVDREFHQVFIL0FnRUFNQjBHQTFVZERnUVdCQlJJTGpLcDNoczFBZ1hGcFZBVApTODB1WlZyeVNUQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFNeGVZQVRJQnlQci9hWFBBL3Y2QW9YUjZoL0RECmRIZWhjbm8wblYzbkZJbGZsVUtxWTJJSWYwM2NuT2tTZ0RzdFNYaVFlanpncVdiU0djd3BtQnhSdHBESzViK0kKTXdiYkFLai9HV0ZIK0xaUXFQK0xiditEaDEvTXRxeE4xZDlrR0dJUHltK2doM3VXNVlUOGVKSGRCY1A0c3hHdQpKR1JHVWtIRjRDaWtTRTI3U2luZkZ3N3pHZWs2OHU2aE1uUEhCVUFLay9WcVR4Tk9VMTFEUTNQYi9GQ2NxcHBvCmpQakJRY3ZkYkVyeXFpajJmcDJoMlNWenR0Q2VUbmthTFM2Z3JTN1BnTzRQQjVDbmdVVU9kckJzdEF1NElyYWYKVUpTNzRpM0ZjMEVUSHpZNG03SHdURWVOWS9rUWR4NXBIaExVUllZVUsvcGgwWFFJV2VYSlRGMlgwQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K', clusterName: 'do-sfo2-k8s-1-27-4-do-0-sfo2-1692186680734', contextName: 'do-sfo2-k8s-1-27-4-do-0-sfo2-1692186680734', credentialsId: 'kubeconfig', namespace: 'default', restrictKubeConfigAccess: false, serverUrl: 'https://bff11845-04ad-4323-9d2b-e03ec8425a3f.k8s.ondigitalocean.com') {
                    sh 'kubectl -n default rollout undo deploy ${deployment_name}'
                }
              }
              throw e
            }
          }
        }
    }
}