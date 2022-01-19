#!/bin/bash
# Script for installing apps for DevOps lab

## Docker CE
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo systemctl enable docker
sudo systemctl start docker

## Portainer CE
sudo docker volume create portainer-data
sudo docker run --detach \
  --publish 8000:8000 --publish 9000:9000 \
  --name=portainer \
  --restart=always \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume portainer-data:/data \
  portainer/portainer-ce
sudo ufw allow 9000/tcp
sudo systemctl restart ufw

## Gitlab CE
export GITLAB_HOME=/srv
sudo docker run --detach \
  --publish 443:443 --publish 80:80 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/gitlab/config:/etc/gitlab:Z \
  --volume $GITLAB_HOME/gitlab/logs:/var/log/gitlab:Z \
  --volume $GITLAB_HOME/gitlab/data:/var/opt/gitlab:Z \
  gitlab/gitlab-ce:latest
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo systemctl restart ufw

## Jenkins
sudo docker run --detach \
  --publish 8080:8080 --publish 50000:50000 \
  --name jenkins \
  --restart always \
  --volume jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
sudo ufw allow 8080/tcp
sudo systemctl restart ufw

## Sonarqube
sudo docker run --detach \
  --publish 7000:7000 \
  --name sonarqube \
  --restart always \
  library/sonarqube:lts
sudo ufw allow 7000/tcp
sudo systemctl restart ufw

## Selenium
sudo docker run --detach \
  --publish 4444:4444 \
  --volume /dev/shm:/dev/shm \
  --name selenium \
selenium/standalone-chrome:3.141.59-yttrium
sudo ufw allow 4444/tcp
sudo systemctl restart ufw
