FROM centos:latest
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
yum install -y wget net-tools telnet git
ln -s /opt/dashboard/Hygieia/UI/node/node /usr/bin/node
ln -s /opt/dashboard/Hygieia/UI/node_modules/.bin/gulp /usr/bin/gulp
mkdir -p /opt/dashboard
cd /opt/dashboard
wget http://www.eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar xzf apache-maven-3.3.9-bin.tar.gz
mkdir -p /usr/local/maven
mv apache-maven-3.3.9/ /usr/local/maven/
ln -s /usr/local/maven/apache-maven-3.3.9/bin/mvn /usr/bin/mvn
ENV JAVA_HOME /usr/lib/cd jvm/java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64/jre
cp /tmp/location_for_dashboard_artifacts/*.jar /tmp/location_for_dashboard_artifacts/*.xml /opt/dashboard
git clone https://github.com/ysbre/Hygieia.git
echo "[Unit]
Description=devopsdash-api Service
After=network.target
[Service]
Type=simple
User=root
ExecStart=/bin/java -jar /opt/dashboard/api.jar --spring.config.location=/opt/dashboard/application.properties
Restart=on-abort
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/devopsdash-api.service
echo "[Unit]
Description=devopsdash-ui Service
After=network.target
[Service]
Type=simple
User=root
WorkingDirectory=/opt/dashboard/Hygieia/UI
ExecStart=/usr/bin/gulp serve
Restart=on-abort
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/devopsdash-ui.service
echo '[Unit]
Description=collector-bitbucket Service
After=network.target
[Service]
Type=simple
User=root
ExecStart=/bin/java -jar /opt/dashboard/bitbucket-scm-collector-3.1.1-SNAPSHOT.jar --spring.config.name=git --spring.config.location=/opt/dashboard/application.properties -Dlogging.config=file:/opt/dashboard/logback_bitbucket.xml
Restart=on-abort
[Install]
WantedBy=multi-user.target
C' > /etc/systemd/system/collector-bitbucket.service
echo '[Unit]
Description=collector-jira Service
After=network.target
[Service]
Type=simple
User=root
ExecStart=/bin/java -jar /opt/dashboard/jira-feature-collector-3.1.1-SNAPSHOT.jar --spring.config.name=feature --spring.config.location=/opt/dashboard/application.properties -Dlogging.config=file:/opt/dashboard/logback_jira.xml
Restart=on-abort
[Install]
WantedBy=multi-user.target' > /etc/systemd/system/collector-jira.service
echo '[Unit]
Description=collector-sonar Service
After=network.target
[Service]
Type=simple
User=root
ExecStart=/bin/java -jar /opt/dashboard/sonar-codequality-collector-3.1.1-SNAPSHOT.jar --spring.config.name=sonar --spring.config.location=/opt/dashboard/application.properties -Dlogging.config=file:/opt/dashboard/logback_sonar.xml
Restart=on-abort
[Install]
WantedBy=multi-user.target' > /etc/systemd/system/collector-jira.service
echo '[Unit]
Description=collector-score Service
After=network.target
[Service]
Type=simple
User=root
ExecStart=/bin/java -jar /opt/dashboard/score-collector-3.1.1-SNAPSHOT.jar --spring.config.name=score --spring.config.location=/opt/dashboard/application.properties -Dlogging.config=file:/opt/dashboard/logback_score.xml
Restart=on-abort
[Install]
WantedBy=multi-user.target' > /etc/systemd/system/collector-score.service
echo '# .bash_profile
# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
# User specific environment and startup programs
PATH=$PATH:$HOME/bin:/opt/dashboard/Hygieia/UI/node:/opt/dashboard/Hygieia/UI/node_modules/.bin
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64/jre
export PATH
export JAVA_HOME
Collapse
' > ~/.bash_profile

systemctl start devopsdash-api.service
systemctl start devopsdash-ui.service
systemctl start collector-bitbucket.service
systemctl start collector-jira.service
systemctl start collector-score.service
