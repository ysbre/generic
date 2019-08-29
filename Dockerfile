FROM centos:latest
CMD yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel wget net-tools telnet git
CMD ln -s /opt/dashboard/Hygieia/UI/node/node /usr/bin/node
CMD ln -s /opt/dashboard/Hygieia/UI/node_modules/.bin/gulp /usr/bin/gulp
CMD mkdir -p /opt/dashboard
WORKDIR /opt/dashboard
CMD wget http://www.eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
CMD tar xzf apache-maven-3.3.9-bin.tar.gz
CMD mkdir -p /usr/local/maven
CMD mv apache-maven-3.3.9/ /usr/local/maven/
CMD ln -s /usr/local/maven/apache-maven-3.3.9/bin/mvn /usr/bin/mvn
ENV JAVA_HOME /usr/lib/cd jvm/java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64/jre
COPY /tmp/location_for_dashboard_artifacts/*.jar /tmp/location_for_dashboard_artifacts/*.xml .
CMD  git clone https://github.com/ysbre/Hygieia.git
COPY devopsdash-api.service /etc/systemd/system/devopsdash-api.service
COPY devopsdash-ui.service /etc/systemd/system/devopsdash-ui.service
COPY collector-jira.service /etc/systemd/system/collector-jira.service
COPY collector-sonar.service /etc/systemd/system/collector-sonar.service
COPY collector-score.service /etc/systemd/system/collector-score.service
COPY collector-bitbucket.service /etc/systemd/system/collector-bitbucket.service

systemctl start devopsdash-api.service
systemctl start devopsdash-ui.service
systemctl start collector-bitbucket.service
systemctl start collector-jira.service
systemctl start collector-score.service
