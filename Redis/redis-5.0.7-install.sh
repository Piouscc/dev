#!/bin/sh
#redis

useradd redis
ver="redis-5.0.7"
wget https://download.cdn.pupuapp.cn/setups/sdk2.0/$ver.tar.gz

tar -xvf redis-5.0.7.tar.gz
cd $ver
make >/dev/null
make PREFIX=/usr/local/redis install

log=/var/log/redis
mkdir -p $log
chown redis:redis $log

mkdir -p /data/redis
chown redis:redis /data/redis

