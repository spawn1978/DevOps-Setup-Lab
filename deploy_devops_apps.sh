#!/bin/bash
# Script for installing apps for DevOps lab

## Docker CE
yum install -y yum-utils
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker

## Portainer CE
docker volume create portainer-data
docker run --detach \
  --publish 8000:8000 --publish 9000:9000 \
  --name=portainer \
  --restart=always \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume portainer-data:/data \
  portainer/portainer-ce
firewall-cmd --add-port 9000/tcp --permanent
firewall-cmd --reload

## Gitlab CE
export GITLAB_HOME=/srv
docker run --detach \
  --publish 443:443 --publish 80:80 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/gitlab/config:/etc/gitlab:Z \
  --volume $GITLAB_HOME/gitlab/logs:/var/log/gitlab:Z \
  --volume $GITLAB_HOME/gitlab/data:/var/opt/gitlab:Z \
  gitlab/gitlab-ce:latest
firewall-cmd --add-port 80/tcp --permanent
firewall-cmd --add-port 443/tcp --permanent
firewall-cmd --reload

## Jenkins
docker run --detach \
  --publish 8080:8080 --publish 50000:50000 \
  --name jenkins \
  --restart always \
  --volume jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
firewall-cmd --add-port 8080/tcp --permanent
firewall-cmd --reload

## Sonarqube
docker run --detach \
  --publish 9000:9000 \
  --name sonarqube \
  --restart always \
  sonarqube/sonarqube:lts
firewall-cmd --add-port 9000/tcp --permanent
firewall-cmd --reload
