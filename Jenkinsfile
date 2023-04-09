pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: build-container
    image: sebastianhutter/godot-runner:main
    command:
    - cat
    tty: true
    resources:
      limits:
        memory: "1Gi"
        cpu: "1"
        nvidia.com/gpu: 1
      requests:
        memory: "1Gi"
        cpu: "1"
"""
        }
    }
    stages {
        stage('Test') {
            steps {
                container('build-container') {
                    sh(
                        script: """
                            # ensure reports folder is empty (auto created by gdunit4)
                            rm -rf ./reports/*
                        """
                    )
                    sh(
                        script: """
                            # run tests, the env var GDUNIT_BIN is setup in the docker image
                            \$GDUNIT_BIN -a ./test
                        """
                    )
                    sh 'echo "Testing your project"'
                }
            }
            post {
                always {
                    container('build-container') {
                        junit '**/target/surefire-reports/TEST-*.xml'
                    }
                }
            }
        }
        stage('Build') {
            when {
                branch 'main'
            }
            steps {
                container('build-container') {
                    // Your deployment steps go here
                    sh 'echo "Deploying your project"'
                }
            }
        }
    }
}
