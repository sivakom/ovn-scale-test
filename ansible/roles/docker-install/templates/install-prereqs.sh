#!/bin/sh

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates linux-image-extra-4.4.0-36-generic linux-image-extra-virtual

sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get purge lxc-docker
sudo apt-get install -y docker-engine
sudo service docker start

sudo apt-get install -y python-pip
pip install -U docker-py netaddr

