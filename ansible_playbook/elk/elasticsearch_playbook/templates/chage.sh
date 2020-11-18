#!/bin/bash

Hostname=`hostname`
IP=`hostname -i`
sed -i "s/#NAME#/${Hostname}/g" /usr/local/elasticsearch-7.9.3/config/elasticsearch.yml
sed -i "s/#IP#/${IP}/g" /usr/local/elasticsearch-7.9.3/config/elasticsearch.yml