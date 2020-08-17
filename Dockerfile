## let's pull the centos 7 image
FROM centos:7

# let's create the main operations directory for the dashboad
RUN mkdir -p /opt/dashboard
WORKDIR /opt/dashboard

## let's install the baseline dependencies for Hygieia such as java - etc
RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel wget net-tools telnet git which make libcurl --nogpgcheck
RUN yum groupinstall -y 'Development Tools'
# RUN yum clean all
RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash -
RUN yum install -y nodejs
RUN curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo
RUN yum install -y yarn

## let's install maven
RUN wget http://www.eu.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
RUN tar xzf apache-maven-3.6.3-bin.tar.gz
RUN mkdir -p /usr/local/maven
RUN mv apache-maven-3.6.3/ /usr/local/maven/
RUN ln -s /usr/local/maven/apache-maven-3.6.3/bin/mvn /usr/bin/mvn
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.262.b10-0.el7_8.x86_64/jre

## let's check the environment
RUN echo "==========================================="
RUN echo "JAVA_HOME = $JAVA_HOME"
RUN java -version
RUN mvn -v
RUN node -v
RUN npm -v 
RUN yarn -v
RUN echo "==========================================="

## let's compile the Hygieia code base
RUN git clone https://github.com/Hygieia/hygieia-core.git
RUN cd /opt/dashboard/hygieia-core && mvn clean install

# note soon to be using angular 
RUN git clone https://github.com/Hygieia/Hygieia.git
# RUN cd /opt/dashboard/Hygieia/UI && npm install && touch /root/.angular-config.json && echo N | npm install -g @angular/cli@8.0.3 && ng version
RUN cd /opt/dashboard/Hygieia/UI && npm install

# RUN git clone https://github.com/Hygieia/api.git
RUN git clone https://ysbre:n9EBMz2uCbmKVCstguCD@bitbucket.org/lumsb-hygieia/api.git
RUN cd /opt/dashboard/api && mvn clean install

# RUN git clone https://github.com/Hygieia/Hygieia.git
RUN cd /opt/dashboard/Hygieia && mvn clean install

## let's compile the collectors
RUN git clone https://github.com/Hygieia/hygieia-scm-bitbucket-collector.git
RUN cd /opt/dashboard/hygieia-scm-bitbucket-collector && mvn install

RUN git clone https://github.com/Hygieia/hygieia-publisher-jenkins-plugin.git
RUN cd /opt/dashboard/hygieia-publisher-jenkins-plugin && mvn clean package

RUN git clone https://github.com/Hygieia/hygieia-misc-score-collector.git
RUN cd /opt/dashboard/hygieia-misc-score-collector && mvn install

RUN git clone https://github.com/Hygieia/hygieia-codequality-sonar-collector.git
RUN cd /opt/dashboard/hygieia-codequality-sonar-collector && mvn install

RUN git clone https://github.com/Hygieia/hygieia-feature-jira-collector.git
RUN cd /opt/dashboard/hygieia-feature-jira-collector && mvn install

RUN git clone https://ysbre:n9EBMz2uCbmKVCstguCD@bitbucket.org/lumsb-hygieia/execdashboard.git
RUN cd /opt/dashboard/execdashboard && mvn -Dpmd.failOnViolation=false clean install

RUN cd /opt/dashboard/execdashboard/exec-ui && npm --depth 9999 update && npm rebuild node-sass

RUN git clone https://ysbre:n9EBMz2uCbmKVCstguCD@bitbucket.org/lumsb-hygieia/hygieia-uptime-pingdom-collector.git
RUN cd /opt/dashboard/hygieia-uptime-pingdom-collector && mvn install


RUN ln -s /opt/dashboard/Hygieia/UI/node_modules/.bin/gulp /usr/bin/gulp

RUN printf "[Unit] \nDescription=devopsdash-api Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/api/target/api.jar --spring.config.location=/opt/dashboard/application.properties \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/devopsdash-api.service

RUN printf "[Unit] \nDescription=devopsdash-ui Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nWorkingDirectory=/opt/dashboard/Hygieia/UI \nExecStart=/usr/bin/gulp serve \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/devopsdash-ui.service

RUN printf "[Unit] \nDescription=collector-jira Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/hygieia-feature-jira-collector/target/jira-feature-collector.jar --spring.config.name=feature --spring.config.location=/opt/dashboard/application.properties -Dlogging.config=file:/opt/dashboard/hygieia-feature-jira-collector/src/main/resources/logback.xml \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/collector-jira.service

RUN printf "[Unit] \nDescription=collector-sonar Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/hygieia-codequality-sonar-collector/target/sonar-codequality-collector.jar --spring.config.name=sonar --spring.config.location=/opt/dashboard/application.properties -Dlogging.config=file:/opt/dashboard/hygieia-codequality-sonar-collector/src/main/resources/logback.xml \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/collector-sonar.service

RUN printf "[Unit] \nDescription=collector-score Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/hygieia-misc-score-collector/target/score-collector.jar --spring.config.name=score --spring.config.location=/opt/dashboard/application.properties -Dlogging.config=file:/opt/dashboard/hygieia-misc-score-collector/src/main/resources/logback.xml \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/collector-score.service

RUN printf "[Unit] \nDescription=collector-bitbucket Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/hygieia-scm-bitbucket-collector/target/bitbucket-scm-collector.jar --spring.config.name=git --spring.config.location=/opt/dashboard/application.properties -Dlogging.config=file:/opt/dashboard/hygieia-scm-bitbucket-collector/src/main/resources/logback.xml \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/collector-bitbucket.service

RUN printf "[Unit] \nDescription=devopsdash-exec-api Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/execdashboard/exec-api/target/exec-api.jar --spring.config.location=/opt/dashboard/api.properties \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/devopsdash-exec-api.service

RUN printf "[Unit] \nDescription=devopsdash-exec-analysis Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/execdashboard/exec-analysis/target/exec-analysis-1.0.0-SNAPSHOT.jar --spring.config.name=portfolio --spring.config.location=/opt/dashboard/analytics.properties \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/devopsdash-exec-analysis.service

RUN printf "[Unit] \nDescription=collector-pingdom Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/hygieia-uptime-pingdom-collector/target/pingdom-uptime-collector.jar --spring.config.location=/opt/dashboard/pingdom.properties \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/collector-pingdom.service

RUN printf "[Unit] \nDescription=devopsdash-exec-ui Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nWorkingDirectory=/opt/dashboard/execdashboard/exec-ui \nExecStart=/usr/bin/npm run prod \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/devopsdash-exec-ui.service

RUN printf "systemctl start devopsdash-api.service \nsleep 10 \nsystemctl start devopsdash-ui.service \nsleep 5 \nsystemctl start collector-bitbucket.service \nsystemctl start collector-jira.service \nsystemctl start collector-score.service \nsystemctl start collector-sonar.service \nsystemctl start devopsdash-exec-api.service \nsystemctl start devopsdash-exec-analysis.service \nsystemctl start collector-pingdom.service \n" > startup.sh

RUN chmod +x ./startup.sh

