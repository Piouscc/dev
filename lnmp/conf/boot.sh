#!/bin/sh

NAME=#NAME#
PREFIX=/opt/$NAME
LOG=/var/$NAME/log
TMP=/tmp/$NAME
WWW_LOG=/var/$NAME/www_log
www=/www/67

plf_id=$2
[ -z $plf_id ] && plf_id=2

if [ "$1" == 'stop' ]; then
	
	nginx -s stop
	fpm stop
	$PREFIX/mysql/mysql.server stop
	#kill `cat /tmp/memcache.pid`
	
else
	! [ -d $TMP ] && mkdir -p $TMP/{php_session,php_upload} && chown www:www -R $TMP
	! [ -d $LOG ] && mkdir -p $LOG
	! [ -d /dev/shm/$NAME ] && mkdir -p /dev/shm/$NAME
	chown www:www /dev/shm/$NAME
	
	nginx
	fpm start
	$PREFIX/mysql/mysql.server start
	
	#$PREFIX/memcache/bin/memcached -d -u nobody -t 8 -c 65535 -m 4096 -p 11211 -P /tmp/memcache.pid
	
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
	su redis -c "$PREFIX/redis/bin/redis-server $PREFIX/redis/redis.conf &"
	#su redis -c "$PREFIX/redis/bin/redis-server /data/redis/sentinel.conf --sentinel &"
	
	ad=$www/adv/data$plf_id/stat
	mkdir -p $ad/raw_ad_logs
	chown www:www $ad
	chown www:www $ad/raw_ad_logs
	
	plf=$www/platform/data$plf_id/stat
	mkdir -p $plf/raw_ad_logs
	chown www:www $plf
	chown www:www $plf/raw_ad_logs
	
	#mount --bind $ad/raw_ad_logs $plf/raw_ad_logs
	
	ipset flush && grep -v '#' /etc/sysconfig/ipset |while read line; do ipset $line; done
	service iptables start
fi
