import groovy.json.*

pipeline {

    agent {
        label 'master'
    }

    environment {
        DOCKER_REPO = "artifactory-east.corp.lumsb.com/re_images/dashboard_docker"
        MAX_VERSIONS = '3'
        MAX_DAYS = '3'
	TAG = v2-"${env.BUILD_ID}"
        RELEASE_BRANCH = "master"
	QA_HOST = "devops-dash02.mgmt.sbs.e1b.lumsb.com"
        FEATURE_BRANCH = "feature_branch"
        SLACK_NOTIFY_DEV_TEAM = "#ysb-re-dev"
        SLACK_NOTIFY_SCRUM_TEAM = "#ystore-re-dev"
    }

    stages {
        stage('Build Docker') {
            steps {
                echo "Building $DOCKER_REPO:$TAG\n"
                sh '''
                docker build --build-arg RETENTION_POLICY_MAX_VERSION=$MAX_VERSIONS --build-arg RETENTION_POLICY_MAX_DAYS=$MAX_DAYS  --compress --rm  -t ${DOCKER_REPO}:${TAG}  -t ${DOCKER_REPO}:latest -f ./Dockerfile .
                '''
                }
            }
       
        stage('Publish Docker') {
            steps {
                sh '''
                echo "\nPushing image $DOCKER_REPO:$TAG to artifactory...\n" 
	        docker push ${DOCKER_REPO}:${TAG} 
	        echo "\nPushing image $DOCKER_REPO:$TAG to artifactory...Done.\n" 
                '''
	        } 
            }
          
/*
        stage('Deploy to QA') {
            steps {
                script {
                    echo "Deploying to QA"
                    saltresult = salt authtype: 'pam', clientInterface: local(arguments: '', blockbuild: true, function: 'chef.client', jobPollTime: 10, target: "${QA_HOST}", targetType: 'glob', minionTimeout: 3000), credentialsId: '0fe75ace-194b-4478-96ac-f85c7a0a9004', servername: 'https://salt.corp.lumsb.com:8000'
                    println(JsonOutput.prettyPrint(saltresult))
                }
            }        
        }

        stage('Deploy to PROD') {
    	    steps {
                script {
		    def PROD = ["devops-dash-fe01.mgmt.sbs.e1a.lumsb.com", "devops-dash-fe02.mgmt.sbs.e1b.lumsb.com"]
                    for (host in PROD) {
                        saltresult = salt authtype: 'pam', clientInterface: local(arguments: '', blockbuild: true, function: 'chef.client', jobPollTime: 10, target: host, targetType: 'glob', minionTimeout: 3000), credentialsId: '0fe75ace-194b-4478-96ac-f85c7a0a9004', servername: 'https://salt.corp.lumsb.com:8000'
                        println(JsonOutput.prettyPrint(saltresult))   
            	    }
                } 
            }
        }
*/
    }
}
