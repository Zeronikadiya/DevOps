pipeline {
    agent any
 
    environment {
        DOCKER_IMAGE = "zeronika/my-java-app"
        DOCKER_TAG   = "${BUILD_NUMBER}"
    }
 
    stages {
 
        stage('Clone') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Zeronikadiya/DevOps.git'
            }
        }
 
        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
 
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
 
        stage('Docker Build') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
            }
        }
 
        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }
 
        // ============================================================
        // KEY FIX: withCredentials injects kubeconfig so kubectl
        // knows where Minikube is. set -x prints every command
        // so you can see output in Jenkins Console.
        // ============================================================
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig',
                                      variable: 'KUBECONFIG')]) {
                    sh '''
                        set -x
 
                        echo "=== Cluster check ==="
                        kubectl get nodes
 
                        echo "=== Applying manifests ==="
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
 
                        echo "=== Updating image ==="
                        kubectl set image deployment/java-app \
                            java-app=${DOCKER_IMAGE}:${DOCKER_TAG}
 
                        echo "=== Waiting for rollout ==="
                        kubectl rollout status deployment/java-app --timeout=120s
 
                        echo "=== Pod and service status ==="
                        kubectl get pods
                        kubectl get services
                    '''
                }
            }
        }
    }
 
    post {
        success {
            echo 'Pipeline succeeded! App is live on Kubernetes.'
        }
        failure {
            withCredentials([file(credentialsId: 'kubeconfig',
                                  variable: 'KUBECONFIG')]) {
                sh '''
                    echo "=== DEBUG: Pod describe ==="
                    kubectl describe pods -l app=java-app || true
                    echo "=== DEBUG: Pod logs ==="
                    kubectl logs -l app=java-app --tail=50 || true
                '''
            }
        }
    }
}
