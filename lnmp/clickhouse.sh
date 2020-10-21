#!/bin/sh

. $(pwd)/include.sh

yum install -y yum-utils unixODBC-devel

#yum install -y centos-release-scl
#yum install -y devtoolset-6-gcc devtoolset-6-gcc-c++
#scl enable devtoolset-6 bash

rpm --import https://repo.yandex.ru/clickhouse/CLICKHOUSE-KEY.GPG
yum-config-manager --add-repo https://repo.yandex.ru/clickhouse/rpm/stable/x86_64
yum install -y clickhouse-server clickhouse-client

wget https://packagecloud.io/Altinity/clickhouse/packages/el/7/clickhouse-odbc-1.0.0.20190611-1.x86_64.rpm/download.rpm

rpm -ivh download.rpm


cat <<EOD >> /home/www/.odbc.ini
[ODBC Data Sources]
Clickhouse = stat67

[stat67]
Driver = /usr/local/lib64/odbc/libclickhouseodbc.so

url = http://localhost:8123
database = stat67

EOD

chown www:www /home/www/.odbc.ini
ln -s /home/www/.odbc.ini /root/.odbc.ini

rm -f /etc/clickhouse-server/users.xml
rm -f /etc/clickhouse-server/config.xml

cp $_PWD/conf/ch-users.xml /etc/clickhouse-server/users.xml
cp $_PWD/conf/ch-config.xml /etc/clickhouse-server/config.xml
systemctl disable clickhouse-server
mv /var/lib/clickhouse /usr/local/clickhouse
