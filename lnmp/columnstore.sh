#!/bin/sh

. $(pwd)/include.sh

yum install -y expect expect-devel snappy snappy-devel boost jemalloc

ver=1.2.2
files=()
#files=(${files[@]} "https://download.cdn.pupuapp.cn/setups/sdk2.0/boost_1_55_0.tar.gz")
files=(${files[@]} "https://download.cdn.pupuapp.cn/setups/sdk2.0/mariadb-columnstore-$ver-1-centos7.x86_64.rpm.tar.gz")
libs=$( download files[@] )

#cd $DOWNLOAD/boost_1_55_0
#./bootstrap.sh --with-libraries=atomic,date_time,exception,filesystem,iostreams,locale,program_options,regex,signals,system,test,thread,timer,log --prefix=/usr
#./b2 install

#yum install -y boost
ldconfig

cd $DOWNLOAD

rpm -ivh mariadb-columnstore-$ver*.rpm

sed -i 's/<TotalUmMemory>10%<\/TotalUmMemory>/<TotalUmMemory>50%<\/TotalUmMemory>/g' /usr/local/mariadb/columnstore/etc/Columnstore.xml
sed -i 's/<TotalPmUmMemory>20%<\/TotalPmUmMemory>/<TotalPmUmMemory>60%<\/TotalPmUmMemory>/g' /usr/local/mariadb/columnstore/etc/Columnstore.xml
sed -i '/\[mysqld\]/a max_length_for_sort_data = 10240' /usr/local/mariadb/columnstore/mysql/my.cnf