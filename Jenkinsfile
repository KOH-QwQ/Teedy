pipeline {
    agent any

    environment {
        // Jenkins 凭据 ID（与「Manage Credentials」里填的 ID 一致）
        DOCKER_HUB_CREDENTIALS = 'dockerhub_credentials'
        // Docker Hub 镜像名：用户名/仓库名
        DOCKER_IMAGE = 'kohqwq/teedy'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = 'teedy-container-8081'
        CONTAINER_PORT = '8081'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Clean') {
            steps {
                sh 'mvn clean'
            }
        }

        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mkdir -p "${WORKSPACE}/.ci-data" && mvn test -Dmaven.test.failure.ignore=true -Ddocs.home="${WORKSPACE}/.ci-data"'
            }
        }

        stage('PMD') {
            steps {
                sh 'mvn install -DskipTests && mvn pmd:pmd'
            }
        }

        stage('JaCoCo') {
            steps {
                sh 'mvn jacoco:report'
            }
        }

        stage('Javadoc') {
            steps {
                sh 'mvn javadoc:javadoc'
            }
        }

        stage('Site') {
            steps {
                sh '''
                    mvn jacoco:report site
                    cp -r docs-core/target/site target/site/docs-core
                    cp -r docs-web-common/target/site target/site/docs-web-common
                    cp -r docs-web/target/site target/site/docs-web
                '''
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Build image') {
            steps {
                script {
                    docker.build("${env.DOCKER_IMAGE}:${env.DOCKER_TAG}")
                }
            }
        }

        stage('Push image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKER_HUB_CREDENTIALS) {
                        def image = docker.image("${env.DOCKER_IMAGE}:${env.DOCKER_TAG}")
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }

        stage('Run container') {
            steps {
                script {
                    sh "docker stop ${env.CONTAINER_NAME} || true"
                    sh "docker rm ${env.CONTAINER_NAME} || true"
                    docker.image("${env.DOCKER_IMAGE}:${env.DOCKER_TAG}").run(
                        "-d --name ${env.CONTAINER_NAME} -p ${env.CONTAINER_PORT}:8080"
                    )
                    sh "docker ps --filter name=${env.CONTAINER_NAME}"
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/target/site/**/*.*', fingerprint: true
            archiveArtifacts artifacts: '**/target/**/*.jar', fingerprint: true
            archiveArtifacts artifacts: '**/target/**/*.war', fingerprint: true
            junit '**/target/surefire-reports/*.xml'
        }
    }
}
