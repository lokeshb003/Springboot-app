pipeline {
    agent any
    environment {
        IMAGE_NAME="lokeshb003/springboot-app:latest"
        applicationURL="170.64.254.221"
        applicationURI="compare/51"
        deployment_name="devsecopsgit "
        serviceName="devsecops-svc"
    }
    stages {
        stage('Build the SpringBoot Application') {
            steps {
                sh 'mvn clean package -DskipTests=true'
                archiveArtifacts artifacts: 'target/*.jar', followSymlinks: false
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
              sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=DevSecOps -Dsonar.projectName=DevSecOps -Dsonar.host.url=http://146.190.163.215:9000 -Dsonar.token=sqp_0a68e4fd2ce21d966a04a7903375c4216d85cc79'
            }
            post {
              always {
                dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
              }
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
            withKubeConfig(caCertificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKekNDQWcrZ0F3SUJBZ0lDQm5Vd0RRWUpLb1pJaHZjTkFRRUxCUUF3TXpFVk1CTUdBMVVFQ2hNTVJHbG4KYVhSaGJFOWpaV0Z1TVJvd0dBWURWUVFERXhGck9ITmhZWE1nUTJ4MWMzUmxjaUJEUVRBZUZ3MHlNekE0TVRrdwpOVEF4TURWYUZ3MDBNekE0TVRrd05UQXhNRFZhTURNeEZUQVRCZ05WQkFvVERFUnBaMmwwWVd4UFkyVmhiakVhCk1CZ0dBMVVFQXhNUmF6aHpZV0Z6SUVOc2RYTjBaWElnUTBFd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUIKRHdBd2dnRUtBb0lCQVFESGl2UlhlcURoYVdsWThsRDJRZkU1TTNXeVVjOGdyb2Z6ZFpLMnJlSndsWWNBVUcwMApURkhDdVN5S0hadEhEMk9kWU1KckVvczRnN3lkNTBjc1R1dSs4QnJsU3MvekRCc2pPTExSNXNaNWVWSmMxVFJkClRHZG5QRzVFUS9BT1UyOGxSTzNaRXFjUnFwU0I0S0w1NWJqYzhidUZSQU9RMlFKR2tLem9OY0V1MUJwYlo5L1AKTHBDKy81QmlIbXMrSUJ0MWF2WFNzbWRTWGkvRnU1b1VFRXVwbDdxYUdLdW53QTZzTGxOZWFlZjFsNXFPVHZmNQpmdnErdlNwRWp4OW5RcWtpdnZpR2hzWjJ3LzM3Z2lFUXZIK09ldVF1ZFVoeXV6c0JrY3AxVFNqV0k0bitlMEpECkFmUnlldS81a1UvQjRTWGwzMFNETittTDhwZkNlT2pzUFZHRkFnTUJBQUdqUlRCRE1BNEdBMVVkRHdFQi93UUUKQXdJQmhqQVNCZ05WSFJNQkFmOEVDREFHQVFIL0FnRUFNQjBHQTFVZERnUVdCQlNWQ21oWjQ5MjlNcVlBQXhtQgpnWjdrTXNhYjhUQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFSUTNHNHVGOFJpTTFsNFJqOExjbzBzZlBROGYzCjRPdlF4MmxXMDZkbFJYRFVIb2Vpb0w2aGNkUXY3dlo0eDcveFR5RTlzNXlQZkZTQTVWSWh0ZnczYTB1bE9IQW8KU0dTbU8xK3ByYVRhYzRDSzdPV3FZSy91aDR1MUc1YmFGRXBqWmhRaDFNUEVvcDZWdmR0bUNPNGdEMmNZWms2WApKVmhCTjJLY1VwbWJFSXEvQzkzT0dBdmJ1YXdNRUtxU3RuNVA2dzh5NFRMaGM4c2JQQUVQN2lUZU94K0grdUk1Cjc4aFNNL3BFbEs2c3BkcmlaTkNrd3BTU0JDaldZdXdkb0g3SDdzNlJOQVdqTDZwVXFaUXNtTWNDTzQ1YlFZU3IKdWJuZ2I5SEFJK0tqL0ZFM3REbHZHWTBETW5pczZJbUFJWDROMlg4RFZlNzhMMFZIQ0VwenhKa05RQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K', clusterName: 'do-syd1-k8s-1-27-4-do-0-syd1-1692421229344', contextName: 'do-syd1-k8s-1-27-4-do-0-syd1-1692421229344', credentialsId: 'kube-config', namespace: 'default', restrictKubeConfigAccess: false, serverUrl: 'https://f0e8a121-5dae-432d-adaa-7b17465951ca.k8s.ondigitalocean.com') {
                    sh 'kubectl apply -f kube-deployment.yaml'
                }
          }
        }
        stage('Integration Test with cURL') {
          steps {
            script {
              try {
                withKubeConfig(caCertificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKekNDQWcrZ0F3SUJBZ0lDQm5Vd0RRWUpLb1pJaHZjTkFRRUxCUUF3TXpFVk1CTUdBMVVFQ2hNTVJHbG4KYVhSaGJFOWpaV0Z1TVJvd0dBWURWUVFERXhGck9ITmhZWE1nUTJ4MWMzUmxjaUJEUVRBZUZ3MHlNekE0TVRrdwpOVEF4TURWYUZ3MDBNekE0TVRrd05UQXhNRFZhTURNeEZUQVRCZ05WQkFvVERFUnBaMmwwWVd4UFkyVmhiakVhCk1CZ0dBMVVFQXhNUmF6aHpZV0Z6SUVOc2RYTjBaWElnUTBFd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUIKRHdBd2dnRUtBb0lCQVFESGl2UlhlcURoYVdsWThsRDJRZkU1TTNXeVVjOGdyb2Z6ZFpLMnJlSndsWWNBVUcwMApURkhDdVN5S0hadEhEMk9kWU1KckVvczRnN3lkNTBjc1R1dSs4QnJsU3MvekRCc2pPTExSNXNaNWVWSmMxVFJkClRHZG5QRzVFUS9BT1UyOGxSTzNaRXFjUnFwU0I0S0w1NWJqYzhidUZSQU9RMlFKR2tLem9OY0V1MUJwYlo5L1AKTHBDKy81QmlIbXMrSUJ0MWF2WFNzbWRTWGkvRnU1b1VFRXVwbDdxYUdLdW53QTZzTGxOZWFlZjFsNXFPVHZmNQpmdnErdlNwRWp4OW5RcWtpdnZpR2hzWjJ3LzM3Z2lFUXZIK09ldVF1ZFVoeXV6c0JrY3AxVFNqV0k0bitlMEpECkFmUnlldS81a1UvQjRTWGwzMFNETittTDhwZkNlT2pzUFZHRkFnTUJBQUdqUlRCRE1BNEdBMVVkRHdFQi93UUUKQXdJQmhqQVNCZ05WSFJNQkFmOEVDREFHQVFIL0FnRUFNQjBHQTFVZERnUVdCQlNWQ21oWjQ5MjlNcVlBQXhtQgpnWjdrTXNhYjhUQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFSUTNHNHVGOFJpTTFsNFJqOExjbzBzZlBROGYzCjRPdlF4MmxXMDZkbFJYRFVIb2Vpb0w2aGNkUXY3dlo0eDcveFR5RTlzNXlQZkZTQTVWSWh0ZnczYTB1bE9IQW8KU0dTbU8xK3ByYVRhYzRDSzdPV3FZSy91aDR1MUc1YmFGRXBqWmhRaDFNUEVvcDZWdmR0bUNPNGdEMmNZWms2WApKVmhCTjJLY1VwbWJFSXEvQzkzT0dBdmJ1YXdNRUtxU3RuNVA2dzh5NFRMaGM4c2JQQUVQN2lUZU94K0grdUk1Cjc4aFNNL3BFbEs2c3BkcmlaTkNrd3BTU0JDaldZdXdkb0g3SDdzNlJOQVdqTDZwVXFaUXNtTWNDTzQ1YlFZU3IKdWJuZ2I5SEFJK0tqL0ZFM3REbHZHWTBETW5pczZJbUFJWDROMlg4RFZlNzhMMFZIQ0VwenhKa05RQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K', clusterName: 'do-syd1-k8s-1-27-4-do-0-syd1-1692421229344', contextName: 'do-syd1-k8s-1-27-4-do-0-syd1-1692421229344', credentialsId: 'kube-config', namespace: 'default', restrictKubeConfigAccess: false, serverUrl: 'https://f0e8a121-5dae-432d-adaa-7b17465951ca.k8s.ondigitalocean.com') {
                    sh 'bash integration-test.sh'
                }
              }
              catch (e) {
                withKubeConfig(caCertificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKekNDQWcrZ0F3SUJBZ0lDQm5Vd0RRWUpLb1pJaHZjTkFRRUxCUUF3TXpFVk1CTUdBMVVFQ2hNTVJHbG4KYVhSaGJFOWpaV0Z1TVJvd0dBWURWUVFERXhGck9ITmhZWE1nUTJ4MWMzUmxjaUJEUVRBZUZ3MHlNekE0TVRrdwpOVEF4TURWYUZ3MDBNekE0TVRrd05UQXhNRFZhTURNeEZUQVRCZ05WQkFvVERFUnBaMmwwWVd4UFkyVmhiakVhCk1CZ0dBMVVFQXhNUmF6aHpZV0Z6SUVOc2RYTjBaWElnUTBFd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUIKRHdBd2dnRUtBb0lCQVFESGl2UlhlcURoYVdsWThsRDJRZkU1TTNXeVVjOGdyb2Z6ZFpLMnJlSndsWWNBVUcwMApURkhDdVN5S0hadEhEMk9kWU1KckVvczRnN3lkNTBjc1R1dSs4QnJsU3MvekRCc2pPTExSNXNaNWVWSmMxVFJkClRHZG5QRzVFUS9BT1UyOGxSTzNaRXFjUnFwU0I0S0w1NWJqYzhidUZSQU9RMlFKR2tLem9OY0V1MUJwYlo5L1AKTHBDKy81QmlIbXMrSUJ0MWF2WFNzbWRTWGkvRnU1b1VFRXVwbDdxYUdLdW53QTZzTGxOZWFlZjFsNXFPVHZmNQpmdnErdlNwRWp4OW5RcWtpdnZpR2hzWjJ3LzM3Z2lFUXZIK09ldVF1ZFVoeXV6c0JrY3AxVFNqV0k0bitlMEpECkFmUnlldS81a1UvQjRTWGwzMFNETittTDhwZkNlT2pzUFZHRkFnTUJBQUdqUlRCRE1BNEdBMVVkRHdFQi93UUUKQXdJQmhqQVNCZ05WSFJNQkFmOEVDREFHQVFIL0FnRUFNQjBHQTFVZERnUVdCQlNWQ21oWjQ5MjlNcVlBQXhtQgpnWjdrTXNhYjhUQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFSUTNHNHVGOFJpTTFsNFJqOExjbzBzZlBROGYzCjRPdlF4MmxXMDZkbFJYRFVIb2Vpb0w2aGNkUXY3dlo0eDcveFR5RTlzNXlQZkZTQTVWSWh0ZnczYTB1bE9IQW8KU0dTbU8xK3ByYVRhYzRDSzdPV3FZSy91aDR1MUc1YmFGRXBqWmhRaDFNUEVvcDZWdmR0bUNPNGdEMmNZWms2WApKVmhCTjJLY1VwbWJFSXEvQzkzT0dBdmJ1YXdNRUtxU3RuNVA2dzh5NFRMaGM4c2JQQUVQN2lUZU94K0grdUk1Cjc4aFNNL3BFbEs2c3BkcmlaTkNrd3BTU0JDaldZdXdkb0g3SDdzNlJOQVdqTDZwVXFaUXNtTWNDTzQ1YlFZU3IKdWJuZ2I5SEFJK0tqL0ZFM3REbHZHWTBETW5pczZJbUFJWDROMlg4RFZlNzhMMFZIQ0VwenhKa05RQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K', clusterName: 'do-syd1-k8s-1-27-4-do-0-syd1-1692421229344', contextName: 'do-syd1-k8s-1-27-4-do-0-syd1-1692421229344', credentialsId: 'kube-config', namespace: 'default', restrictKubeConfigAccess: false, serverUrl: 'https://f0e8a121-5dae-432d-adaa-7b17465951ca.k8s.ondigitalocean.com') {
                    sh 'kubectl -n default rollout undo deploy ${deployment_name}'
                }
              }
            }
          }
        }
        stage('OWASP ZAP API SCAN') {
          steps {
            withKubeConfig(caCertificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKekNDQWcrZ0F3SUJBZ0lDQm5Vd0RRWUpLb1pJaHZjTkFRRUxCUUF3TXpFVk1CTUdBMVVFQ2hNTVJHbG4KYVhSaGJFOWpaV0Z1TVJvd0dBWURWUVFERXhGck9ITmhZWE1nUTJ4MWMzUmxjaUJEUVRBZUZ3MHlNekE0TVRrdwpOVEF4TURWYUZ3MDBNekE0TVRrd05UQXhNRFZhTURNeEZUQVRCZ05WQkFvVERFUnBaMmwwWVd4UFkyVmhiakVhCk1CZ0dBMVVFQXhNUmF6aHpZV0Z6SUVOc2RYTjBaWElnUTBFd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUIKRHdBd2dnRUtBb0lCQVFESGl2UlhlcURoYVdsWThsRDJRZkU1TTNXeVVjOGdyb2Z6ZFpLMnJlSndsWWNBVUcwMApURkhDdVN5S0hadEhEMk9kWU1KckVvczRnN3lkNTBjc1R1dSs4QnJsU3MvekRCc2pPTExSNXNaNWVWSmMxVFJkClRHZG5QRzVFUS9BT1UyOGxSTzNaRXFjUnFwU0I0S0w1NWJqYzhidUZSQU9RMlFKR2tLem9OY0V1MUJwYlo5L1AKTHBDKy81QmlIbXMrSUJ0MWF2WFNzbWRTWGkvRnU1b1VFRXVwbDdxYUdLdW53QTZzTGxOZWFlZjFsNXFPVHZmNQpmdnErdlNwRWp4OW5RcWtpdnZpR2hzWjJ3LzM3Z2lFUXZIK09ldVF1ZFVoeXV6c0JrY3AxVFNqV0k0bitlMEpECkFmUnlldS81a1UvQjRTWGwzMFNETittTDhwZkNlT2pzUFZHRkFnTUJBQUdqUlRCRE1BNEdBMVVkRHdFQi93UUUKQXdJQmhqQVNCZ05WSFJNQkFmOEVDREFHQVFIL0FnRUFNQjBHQTFVZERnUVdCQlNWQ21oWjQ5MjlNcVlBQXhtQgpnWjdrTXNhYjhUQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFSUTNHNHVGOFJpTTFsNFJqOExjbzBzZlBROGYzCjRPdlF4MmxXMDZkbFJYRFVIb2Vpb0w2aGNkUXY3dlo0eDcveFR5RTlzNXlQZkZTQTVWSWh0ZnczYTB1bE9IQW8KU0dTbU8xK3ByYVRhYzRDSzdPV3FZSy91aDR1MUc1YmFGRXBqWmhRaDFNUEVvcDZWdmR0bUNPNGdEMmNZWms2WApKVmhCTjJLY1VwbWJFSXEvQzkzT0dBdmJ1YXdNRUtxU3RuNVA2dzh5NFRMaGM4c2JQQUVQN2lUZU94K0grdUk1Cjc4aFNNL3BFbEs2c3BkcmlaTkNrd3BTU0JDaldZdXdkb0g3SDdzNlJOQVdqTDZwVXFaUXNtTWNDTzQ1YlFZU3IKdWJuZ2I5SEFJK0tqL0ZFM3REbHZHWTBETW5pczZJbUFJWDROMlg4RFZlNzhMMFZIQ0VwenhKa05RQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K', clusterName: 'do-syd1-k8s-1-27-4-do-0-syd1-1692421229344', contextName: 'do-syd1-k8s-1-27-4-do-0-syd1-1692421229344', credentialsId: 'kube-config', namespace: 'default', restrictKubeConfigAccess: false, serverUrl: 'https://f0e8a121-5dae-432d-adaa-7b17465951ca.k8s.ondigitalocean.com') {
                    sh 'bash zap.sh'
                }
          }
          post {
            always {
              publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report_scan.html', reportName: 'OWASP ZAP REPORT HTML', reportTitles: '', useWrapperFileDirectly: true])
            }
          }
        }
    }
}