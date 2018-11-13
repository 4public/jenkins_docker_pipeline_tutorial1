#!/usr/bin/env bash

#check your ports are free
#sudo lsof -i tcp:8080 &&  sudo lsof -i tcp:9001

jenkins_port=8080
sonar_port=9001

sudo docker pull jenkins/jenkins:2.138.3
sudo docker pull library/sonarqube:6.7.5

if [ ! -d downloads ]; then
    mkdir downloads
    cd downloads
    curl -O http://mirror.cnop.net/jdk/linux/jdk-8u171-linux-x64.tar.gz
    curl -O http://mirror.cnop.net/jdk/linux/jdk-7u80-linux-x64.tar.gz
    curl -O http://apache.mirror.anlx.net/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
    cd ..
fi

chmod -R 777  downloads  groovy  jobs  m2deps

sudo docker stop mysonar myjenkins

sudo docker build --no-cache  -t myjenkins .


sudo docker run  -p ${sonar_port}:9000 --rm --name mysonar sonarqube:6.7.5 &

#IP=$(ifconfig en0 | awk '/ *inet /{print $2}')
IP=$(ifconfig eth1 | awk '/ *inet /{print $2}')

echo "Host ip: ${IP}"

if [ ! -d m2deps ]; then
    mkdir m2deps
fi

sudo docker run -p ${jenkins_port}:8080  -v `pwd`/downloads:/var/jenkins_home/downloads:Z \
    -v `pwd`/jobs:/var/jenkins_home/jobs:Z \
    -v `pwd`/m2deps:/var/jenkins_home/.m2/repository:Z --rm --name myjenkins \
    -e SONARQUBE_HOST=http://${IP}:${sonar_port} \
    myjenkins:latest
