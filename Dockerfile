FROM centos:latest
CMD yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel wget net-tools telnet git
CMD ln -s /opt/dashboard/Hygieia/UI/node/node /usr/bin/node
CMD ln -s /opt/dashboard/Hygieia/UI/node_modules/.bin/gulp /usr/bin/gulp
CMD mkdir -p /opt/dashboard
WORKDIR /opt/dashboard

COPY ./*.jar ./*.xml ./
CMD  git clone https://github.com/ysbre/Hygieia.git
COPY devopsdash-api.service /etc/systemd/system/devopsdash-api.service
COPY devopsdash-ui.service /etc/systemd/system/devopsdash-ui.service
COPY collector-jira.service /etc/systemd/system/collector-jira.service
COPY collector-sonar.service /etc/systemd/system/collector-sonar.service
COPY collector-score.service /etc/systemd/system/collector-score.service
COPY collector-bitbucket.service /etc/systemd/system/collector-bitbucket.service
COPY startup.sh ./
RUN chmod +x ./startup.sh
ENTRYPOINT ./startup.sh
