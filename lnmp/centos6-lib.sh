#!/bin/sh

. $(pwd)/include.sh

yum -y install epel-release
yum -y install wget nc telnet gcc gcc-c++ autoconf cmake bison libevent libevent-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel libcurl libcurl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers libpcap libpcap-devel libtool iptables iptables-services rsync file perl perl-DBD-MySQL perl-devel sysstat mailx ntpdate vim jwhois bind-utils git ipset ipset-service tcpdump iftop inotify-tools gcc-g77 vsftpd subversion strace java python-pip net-tools mtr gettext gettext-devel

yum -y update
yum -y groupinstall development tools
pip install ngxtop







lock=$_PWD/env.lock
if [ -f $lock ]; then
	exit
fi
touch $lock

#ulimit
sed -i -r 's|#\*(\s+)soft(\s+)core(\s+)0|*\1soft\2core\30|' /etc/security/limits.conf
sed -i -r 's|#\*(\s+)hard(\s+)rss(\s+)10000|*\1hard\2rss\310000|' /etc/security/limits.conf

echo '/usr/local/lib' >> /etc/ld.so.conf
sleep 2
ldconfig


#ssh
sed -i -r 's|#auth(\s+)required(\s+)pam_wheel.so|auth\1required\1pam_wheel.so|g' /etc/pam.d/su


sed -i -r 's/^#?PubkeyAuthentication\s+(yes|no)/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i -r 's|^#?AuthorizedKeysFile(\s+)\.ssh/authorized_keys|AuthorizedKeysFile\1.ssh/authorized_keys|' /etc/ssh/sshd_config
sed -i -r 's/^#?PasswordAuthentication\s+(yes|no)/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i -r 's/^#?PermitEmptyPasswords\s+(yes|no)/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i -r 's/^#?ClientAliveInterval\s+[0-9]+/ClientAliveInterval 30/' /etc/ssh/sshd_config
sed -i -r 's/^#?ClientAliveCountMax\s+[0-9]+/ClientAliveCountMax 30/' /etc/ssh/sshd_config






ssh-keygen -t dsa -b 1024 -P "" -f /root/.ssh/id_dsa

>> ~/.ssh/authorized_keys
chmod 0644 ~/.ssh/authorized_keys
restorecon -R -v ~/.ssh/

echo 'StrictHostKeyChecking no' >> ~/.ssh/config
echo 'UserKnownHostsFile /dev/null' >> ~/.ssh/config


systemctl disable firewalld
systemctl stop firewalld
systemctl enable iptables ipset
systemctl start iptables ipset

cat $_PWD/conf/iptables > /etc/sysconfig/iptables
cat $_PWD/conf/ipset > /etc/sysconfig/ipset


sed -i -r 's#IPTABLES_MODULES_UNLOAD="yes"#IPTABLES_MODULES_UNLOAD="no"#g' /etc/sysconfig/iptables-config
sed -i -r 's#IPTABLES_MODULES=""#IPTABLES_MODULES="ip_nat_ftp ip_conntrack_ftp"#g' /etc/sysconfig/iptables-config



service sshd reload 


useradd www
mkdir -p /home/www/.ssh/ && chown -R www.www /home/www/.ssh/
touch /home/www/.ssh/authorized_keys && chmod 0600 /home/www/.ssh/authorized_keys
chown www:www /home/www/.ssh/ -R
mkdir /www && chown www:www /www
mkdir -p /www/67/svn
chown www:www /www/67/svn

mkdir -p /var/$NAME/{www_log,log}
chown www:www /var/$NAME/{www_log,log}






cat <<EOD >> /etc/security/limits.conf

#####
*	soft	nofile	65535
*	hard	nofile	65535

*	soft	nproc	65535
*	hard	nproc	65535

root	soft	nproc	65535
root	hard	nproc	65535

root	soft	nofile	65535
root	hard	nofile	65535
#
mysql	soft	nproc	65500
mysql	hard	nproc	65500
#
mysql	soft	nofile	65500
mysql	hard	nofile	65500

redis	soft	nproc	65500
redis	hard	nproc	65500
#
redis	soft	nofile	65500
redis	hard	nofile	65500
#
www	soft	nproc	65535
www	hard	nproc	65535

www	soft	nofile	65535
www	hard	nofile	65535

#####
EOD


cat <<EOD >> /etc/sysctl.conf



#####
net.ipv4.tcp_max_syn_backlog = 819200
net.core.netdev_max_backlog =  327680
net.core.somaxconn = 32768
#
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
#
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
#
net.ipv4.tcp_tw_recycle = 1
#net.ipv4.tcp_tw_len = 1
#net.ipv4.tcp_tw_reuse = 1
#
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
#
#net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 120
net.ipv4.ip_local_port_range = 1024  65535
net.ipv4.ip_conntrack_max = 10240
#
net.netfilter.nf_conntrack_max = 655360
net.netfilter.nf_conntrack_tcp_timeout_established = 600
#
net.ipv4.tcp_max_tw_buckets = 30000

net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0

net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_reordering = 5
net.ipv4.tcp_retrans_collapse = 0

#####

vm.swappiness = 0
vm.min_free_kbytes = 1048576
vm.overcommit_memory = 1
EOD

sysctl -p


cat <<EOD >> /etc/hosts




#####
127.0.0.1		stat.mysql.67.com
127.0.0.1		ad.mysql.67.com cp.mysql.67.com
127.0.0.1		mysql.67.com cache.67.com
	127.0.0.1	cache2.67.com
	127.0.0.1	cache3.67.com
EOD


echo "alias lvscmd='sh /www/67/shell/lvs/ssh.sh cmd '" >> /root/.bashrc
echo "alias lvsrsync='sh /www/67/shell/lvs/ssh.sh rsync '" >> /root/.bashrc

crontab -l > .cron
cat $(pwd)/conf/crontab >> .cron
sed -i 's/$/\n/g' .cron
crontab .cron

