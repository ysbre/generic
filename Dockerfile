## let's pull the centos 7 image
FROM centos:7

## let's install the baseline dependencies for Hygieia such as java - etc
RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel wget net-tools telnet git which libcurl --nogpgcheck
RUN yum clean all

RUN curl -sL https://rpm.nodesource.com/setup_10.x | bash -
RUN yum install -y nodejs

## let's install maven
RUN wget http://www.eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
RUN tar xzf apache-maven-3.3.9-bin.tar.gz
RUN mkdir -p /usr/local/maven
RUN mv apache-maven-3.3.9/ /usr/local/maven/
RUN ln -s /usr/local/maven/apache-maven-3.3.9/bin/mvn /usr/bin/mvn
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.252.b09-2.el7_8.x86_64/jre

## let's create the main operations directory for the dashboad
RUN mkdir -p /opt/dashboard
WORKDIR /opt/dashboard

RUN git clone https://github.com/Hygieia/hygieia-core.git
RUN cd /opt/dashboard/hygieia-core && mvn clean install

RUN git clone https://github.com/Hygieia/api.git
RUN cd /opt/dashboard/api && mvn clean install

RUN git clone https://github.com/Hygieia/Hygieia.git
RUN cd /opt/dashboard/Hygieia && mvn clean install

RUN git clone https://github.com/Hygieia/hygieia-scm-bitbucket-collector.git
RUN cd /opt/dashboard/hygieia-scm-bitbucket-collector && mvn install

RUN git clone https://github.com/Hygieia/hygieia-publisher-jenkins-plugin.git
RUN cd /opt/dashboard/hygieia-publisher-jenkins-plugin && mvn install package

RUN git clone https://github.com/Hygieia/hygieia-misc-score-collector.git
RUN cd /opt/dashboard/hygieia-misc-score-collector && mvn install package

RUN git clone https://github.com/Hygieia/hygieia-codequality-sonar-collector.git
RUN cd /opt/dashboard/hygieia-codequality-sonar-collector && mvn install package

RUN git clone https://github.com/Hygieia/hygieia-feature-jira-collector.git
RUN cd /opt/dashboard/hygieia-feature-jira-collector && mvn install package

RUN git clone https://github.com/Hygieia/ExecDashboard.git
RUN cd /opt/dashboard/ExecDashboard && mvn install

RUN ln -s /opt/dashboard/Hygieia/UI/node_modules/.bin/gulp /usr/bin/gulp

RUN printf "[Unit] \nDescription=devopsdash-api Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/api/target/api.jar --spring.config.location=/opt/dashboard/application.properties \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/devopsdash-api.service

RUN printf "[Unit] \nDescription=devopsdash-ui Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nWorkingDirectory=/opt/dashboard/Hygieia/UI \nExecStart=/usr/bin/gulp serve \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/devopsdash-ui.service

RUN printf "[Unit] \nDescription=collector-jira Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/hygieia-feature-jira-collector/target/jira-feature-collector.jar --spring.config.name=feature --spring.config.location=/opt/dashboard/application.properties -Dlogging.config=file:/opt/dashboard/hygieia-feature-jira-collector/src/main/resources/logback.xml \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/collector-jira.service

RUN printf "[Unit] \nDescription=collector-sonar Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/hygieia-codequality-sonar-collector/target/sonar-codequality-collector.jar --spring.config.name=sonar --spring.config.location=/opt/dashboard/application.properties -Dlogging.config=file:/opt/dashboard/hygieia-codequality-sonar-collector/src/main/resources/logback.xml \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/collector-sonar.service

RUN printf "[Unit] \nDescription=collector-score Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/hygieia-misc-score-collector/target/score-collector.jar --spring.config.name=score --spring.config.location=/opt/dashboard/application.properties -Dlogging.config=file:/opt/dashboard/hygieia-misc-score-collector/src/main/resources/logback.xml \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/collector-score.service

RUN printf "[Unit] \nDescription=collector-bitbucket Service \nAfter=network.target \n[Service] \nType=simple \nUser=root \nExecStart=/bin/java -jar /opt/dashboard/hygieia-scm-bitbucket-collector/target/bitbucket-scm-collector.jar --spring.config.name=git --spring.config.location=/opt/dashboard/application.properties -Dlogging.config=file:/opt/dashboard/hygieia-scm-bitbucket-collector/src/main/resources/logback.xml \nRestart=on-abort \n[Install] \nWantedBy=multi-user.target \n" > /etc/systemd/system/collector-bitbucket.service

RUN printf "systemctl start devopsdash-api.service \nsystemctl start devopsdash-ui.service \nsystemctl start collector-bitbucket.service \nsystemctl start collector-jira.service \nsystemctl start collector-score.service \nsystemctl start collector-sonar.service \n" > startup.sh

RUN chmod +x ./startup.sh
