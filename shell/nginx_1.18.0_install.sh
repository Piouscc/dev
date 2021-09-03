#!/bin/bash

rpm -qa | grep nginx |xargs rpm  --nodeps

yum -y install gcc gcc-c++ wget 

Nginx_Ver=1.18.0
Pcre_Ver=8.44
Zlib_Ver=1.2.11
Openssl_Ver=1.1.1i

USER=www
group=www
useradd $USER
PREFIX=/opt/67_serv
DOWNLOAD_PATH=/usr/local/src
cd $DOWNLOAD_PATH

Pcre_file=https://ftp.pcre.org/pub/pcre/pcre-$Pcre_Ver.tar.gz
Zlib_file=https://download.cdn.pupuapp.cn/setups/sdk2.0/zlib-$Zlib_Ver.tar.gz
Openssl_file=https://www.openssl.org/source/old/1.1.1/openssl-$Openssl_Ver.tar.gz
Nginx_file=http://nginx.org/download/nginx-$Nginx_Ver.tar.gz

#下载所需PG
DOWNLOAD_FILE(){
    for i in $Pcre_file $Zlib_file $Openssl_file $Nginx_file
    do
        PG_name=`basename $i`
        wget -O $PG_name $i
        if [[ $? -ne 0 ]];then
            wget -O $PG_name $i
            if [[ $? -ne 0 ]];then
                echo "文件下载失败"
            fi
        fi
        tar -xf $PG_name
    done
}
echo "--------------下载所需PG------------"
DOWNLOAD_FILE
echo "--------------下载PG完成------------"

cd nginx-$Nginx_Ver

./configure --prefix=$PREFIX/nginx --user=$USER --group=$USER \
	--with-pcre=$DOWNLOAD_PATH/pcre-$Pcre_Ver \
	--with-openssl=$DOWNLOAD_PATH/openssl-$Openssl_Ver \
	--with-zlib=$DOWNLOAD_PATH/zlib-$Zlib_Ver \
	--with-http_sub_module \
	--with-http_v2_module \
	--with-http_gzip_static_module \
	--with-http_realip_module \
	--with-http_stub_status_module --with-http_ssl_module > $DOWNLOAD_PATH/nginx.log

make -j4 >> $DOWNLOAD_PATH/nginx.log
make install >> $DOWNLOAD_PATH/nginx.log

ln $PREFIX/nginx/sbin/nginx /sbin/nginx -sf

#删除下载暂存文件
rm -rf $DOWNLOAD_PATH/*