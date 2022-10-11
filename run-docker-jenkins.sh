#!/bin/bash

[[ $(docker network ls | grep jenkins) ]] || docker network create jenkins && echo "jenkins network exists"

if [[ $(docker ps -q -f name=jenkins | wc -l) -ge 2 ]]
then

  echo "Jenkins containers are already running"
  docker ps -f name=jenkins

elif [[ $(docker ps -aqf name=jenkins | wc -l) -eq 2 ]]
then
  docker start jenkins docker-jenkins
else

docker run \
  --name jenkins \
  --restart=on-failure \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  jenkins/jenkins:lts-jdk11

docker run \
  --name docker-jenkins \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins_data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind \
  --storage-driver overlay2

fi
