#!/bin/sh

. $(pwd)/include.sh

#redis
useradd redis
ver="redis-5.0.7"
files=()
files=(${files[@]} "https://download.cdn.pupuapp.cn/setups/sdk2.0/$ver.tar.gz")
download files[@]

cd $ver
make >/dev/null
make PREFIX=$PREFIX/redis install

log=/var/$NAME/log/redis
mkdir -p $log
chown redis:redis $log

mkdir -p /data/redis
chown redis:redis /data/redis

sed -r "s|#NAME#|$NAME|g" $_PWD/conf/redis.conf > $PREFIX/redis/redis.conf
sed -r "s|#NAME#|$NAME|g" $_PWD/conf/sentinel.conf > /data/redis/sentinel.conf

chown redis:redis /data/redis/sentinel.conf
