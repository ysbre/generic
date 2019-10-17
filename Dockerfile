FROM centos:latest
RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel wget net-tools telnet git which
RUN yum clean all


RUN wget http://www.eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
RUN tar xzf apache-maven-3.3.9-bin.tar.gz
RUN mkdir -p /usr/local/maven
RUN mv apache-maven-3.3.9/ /usr/local/maven/
RUN ln -s /usr/local/maven/apache-maven-3.3.9/bin/mvn /usr/bin/mvn
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64/jre

RUN mkdir -p /opt/dashboard
WORKDIR /opt/dashboard

COPY ./*.jar ./*.xml ./
RUN  git clone https://github.com/ysbre/hygieia-core.git 
RUN cd /opt/dashboard/hygieia-core && git checkout ysbqa && mvn clean install


RUN git clone https://github.com/ysbre/api.git
RUN cd /opt/dashboard/api && git checkout ysbqa && mvn clean install

RUN  git clone https://github.com/ysbre/Hygieia.git 
RUN cd /opt/dashboard/Hygieia && git checkout ysbqa && mvn clean install

RUN ln -s /opt/dashboard/Hygieia/UI/node/node /usr/bin/node && ln -s /opt/dashboard/Hygieia/UI/node_modules/.bin/gulp /usr/bin/gulp

COPY devopsdash-api.service /etc/systemd/system/devopsdash-api.service
COPY devopsdash-ui.service /etc/systemd/system/devopsdash-ui.service
COPY collector-jira.service /etc/systemd/system/collector-jira.service
COPY collector-sonar.service /etc/systemd/system/collector-sonar.service
COPY collector-score.service /etc/systemd/system/collector-score.service
COPY collector-bitbucket.service /etc/systemd/system/collector-bitbucket.service
COPY startup.sh ./
RUN chmod +x ./startup.sh
