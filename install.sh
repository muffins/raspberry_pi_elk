#!/bin/bash

#set -e

ES_VERSION='2.4.1'
ES_DATA_STORE='/opt/es/data'
KIBANA_VERSION='4.6.1'
LS_VERSION='2.4.0'
GIT_DIR=$(pwd)

sudo mkdir -p /usr/share/elasticsearch
sudo mkdir -p /etc/elasticsearch
sudo mkdir -p $ES_DATA_STORE
sudo mkdir -p /opt/logstash
sudo mkdir -p /opt/logstash/vendor/jar/jni/arm-Linux
sudo mkdir -p /etc/logstash/conf.d
sudo mkdir -p /var/log/logstash
sudo mkdir -p /opt/kibana
sudo mkdir -p /opt/kibana/node/bin/node
sudo mkdir -p /opt/kibana/node/bin/npm

# Install re-reqs
sudo apt-get install -y ant zip

sudo wget -O /tmp/elasticsearch.tgz https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/${ES_VERSION}/elasticsearch-${ES_VERSION}.tar.gz
sudo wget -O /tmp/kibana.tgz https://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz
sudo wget -O /tmp/logstash.tgz https://download.elastic.co/logstash/logstash/logstash-${LS_VERSION}.tar.gz
sudo wget -O /tmp/node_latest_armhf.deb http://node-arm.herokuapp.com/node_latest_armhf.deb
sudo git clone https://github.com/jnr/jffi.git /tmp/jffi

sudo tar -zxvf /tmp/elasticsearch.tgz -C /usr/share/elasticsearch
sudo tar -zxvf /tmp/logstash.tgz -C /opt/logstash
sudo tar -zxvf /tmp/kibana.tgz /C /opt/kibana

sudo cp /usr/share/elasticsearch/elasticsearch-${ES_VERSOIN}/config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
sudo cp /usr/share/elasticsearch/elasticsearch-${ES_VERSION}/* /usr/share/elasticsearch/
sudo cp /usr/share/logstash/logstash-$LS_VERSION/* /usr/share/logstash/

sudo sed -i '/#cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml
sudo sed -i "/#path.data: \/path\/to\/data/a path.data: $ES_DATA_STORE" /etc/elasticsearch/elasticsearch.yml

cd /tmp/jffi/
sudo ant jar
sudo cp /tmp/jffi/build/jni/libjffi-1.2.so /opt/logstash/vendor/jar/jni/arm-Linux/
cd /opt/logstash/vendor/jar
sudo zip -g jruby-complete-1.7.11.jar jni/arm-Linux/libjffi-1.2.so

sudo apt-get remove nodered
sudo apt-get remove nodejs nodejs-legacy
sudo apt-get remove npm
sudo dpkg -i /tmp/node_latest_armhf.deb
sudo mv /opt/kibana/node/bin/node /opt/kibana/node/bin/node.orig
sudo mv /opt/kibana/node/bin/npm /opt/kibana/node/bin/npm.orig
sudo ln -s /usr/local/bin/node /opt/kibana/node/bin/node
sudo ln -s /usr/local/bin/npm /opt/kibana/node/bin/npm

sudo rm -rf /tmp/elasticsearch*
sudo rm -rf /tmp/kibana*
sudo rm -rf /tmp/logstash*

sudo cp $GIT_DIR/init.d/kibana /etc/init.d/kibana
sudo cp $GIT_DIR/init.d/logstash /etc/init.d/logstash
sudo cp $GIT_DIR/init.d/elasticsearch /etc/init.d/elasticsearch

sudo chmod 755 /etc/init.d/kibana
sudo chmod 755 /etc/init.d/logstash
sudo chmod 755 /etc/init.d/elasticsearch

sudo update-rc.d kibana defaults
sudo update-rc.d logstash defaults
sudo update-rc.d elasticsearch defaults
