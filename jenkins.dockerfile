FROM jenkins/jenkins:2.361.1-lts
ARG UID=1000
ARG GID=1000
USER root
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/plugins.txt --verbose
RUN usermod -u $UID -g $GID jenkins
USER jenkins