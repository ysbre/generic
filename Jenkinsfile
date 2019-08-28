pipeline {
    agent {
        label 'qa'
    }
    environment {
        DOCKER_REPO = "artifactory-east.corp.lumsb.com/re_images/dashboard_docker"
        MAX_VERSIONS = 3
        MAX_DAYS = 3
        TAG = $BUILD_ID
        RELEASE_BRANCH = "master"
        FEATURE_BRANCH = "feature_branch"
        SLACK_NOTIFY_DEV_TEAM = "#ysb-catalog-manager"
        SLACK_NOTIFY_SCRUM_TEAM = "#ystore-bib-project"
    }
    stages {
        
        stage('Build Docker') {
            steps {
                echo "Building $DOCKER_REPO:$TAG\n"
                sh '''
                    docker build \
                      --build-arg RETENTION_POLICY_MAX_VERSION=$MAX_VERSIONS \
                      --build-arg RETENTION_POLICY_MAX_DAYS=$MAX_DAYS \
                      --compress --rm \
                      -t ${DOCKER_REPO}:${TAG} \
                      -t ${DOCKER_REPO}:latest \
                      -f ./Dockerfile
                      '''
            }
        }
       
      
        stage('Publish Docker') {
            steps {
                sh '''
                echo "\nPushing image $DOCKER_REPO:$TAG to artifactory...\n" 
	              docker push ${DOCKER_REPO}:${TAG} >> $LOG_FILE
	              echo "\nPushing image $DOCKER_REPO:$TAG to artifactory...Done.\n" 
                '''
		       } 
        }
          
        stage('Deploy to QA') {
            steps {
               echo "Deploying to QA"
            }        
        }
    }
}
