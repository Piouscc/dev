#!/bin/bash

#安装依赖
yum -y install epel-release
yum -y install wget nc telnet gcc gcc-c++ autoconf cmake bison libevent libevent-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel libcurl libcurl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers libpcap libpcap-devel libtool iptables iptables-services rsync file perl perl-DBD-MySQL perl-devel sysstat mailx ntpdate vim jwhois bind-utils git ipset ipset-service tcpdump iftop inotify-tools gcc-g77 vsftpd subversion strace java python-pip net-tools mtr gettext gettext-devel

#由于redis6.0需要安装gcc_9.0
yum -y install centos-release-scl
yum -y install devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-binutils
echo "scl enable devtoolset-9 bash" >> /etc/profile
source /etc/profile


#redis-6.0部署脚本
function install_redis () {
        cd /usr/local/src
        if [ ! -f " redis-6.0.1.tar.gz" ]; then
           wget http://download.redis.io/releases/redis-6.0.1.tar.gz
        fi
        cd /usr/local/src
        tar -zxvf /usr/local/src/redis-6.0.1.tar.gz
        cd redis-6.0.1
        make PREFIX=/usr/local/redis install
        mkdir -p /usr/local/redis/{etc,var}
        rsync -avz redis.conf  /usr/local/redis/etc/
        rsync -avz sentinel.conf  /usr/local/redis/etc/
		sed -i "s@logfile.*@logfile /usr/local/redis/var/redis.log@" /usr/local/redis/etc/redis.conf  #相当于替换
        sed -i "s@^dir.*@dir /usr/local/redis/var@" /usr/local/redis/etc/redis.conf					  #相当于替换
        sed -i 's/daemonize no/daemonize yes/g' /usr/local/redis/etc/redis.conf
        sed -i 's/^# bind 127.0.0.1/bind 127.0.0.1/g' /usr/local/redis/etc/redis.conf
}

install_redis
