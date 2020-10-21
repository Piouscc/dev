#!/bin/bash

yum -y install gcc gcc-c++ telnet-server* pam-devel zlib-devel openssl openssl-devel
cd /usr/local/src
wget http://down.i.my71.com/openssh-7.4p1.tar.gz

tar -xvf openssh-7.4p1.tar.gz && cd openssh-7.4p1
./configure --prefix=/usr/local/openssh --sysconfdir=/etc/ssh --with-pam --with-md5-passwords --mandir=/usr/share/man
make && make install
/etc/init.d/sshd stop
\cp -f /usr/local/src/openssh-7.4p1/contrib/redhat/sshd.init /etc/init.d/sshd
chmod u+x /etc/init.d/sshd
\cp -f /usr/local/openssh/sbin/sshd /usr/sbin/sshd
\cp -f /usr/local/openssh/bin/ssh-keygen /usr/bin/ssh-keygen
sed -i 's/GSSAPIAuthentication yes/#GSSAPIAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/GSSAPICleanupCredentials yes/#GSSAPICleanupCredentials yes/g' /etc/ssh/sshd_config
sed -i 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config