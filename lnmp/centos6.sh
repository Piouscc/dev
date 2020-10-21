#!/bin/sh


#iptables, 80 port
#crontab, 
#ssh keys

. $(pwd)/include.sh

sh $_PWD/centos6-lib.sh

sh $_PWD/nginx.sh
sh $_PWD/php-7.3.sh


sed -r "s|#NAME#|$NAME|g" $_PWD/conf/boot.sh > $PREFIX/boot.sh
chmod a+x $PREFIX/boot.sh
echo $PREFIX/boot.sh >> /etc/rc.d/rc.local
echo 'mount --bind /www/67/adv/data2/stat/raw_ad_logs /www/67/platform/data2/stat/raw_ad_logs' >> /etc/rc.d/rc.local
chmod a+x /etc/rc.d/rc.local
