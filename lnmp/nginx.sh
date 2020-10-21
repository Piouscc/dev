#!/bin/sh

. $(pwd)/include.sh

pcre="8.42"
zlib="1.2.11"
openssl="1.0.2q"
nginx="1.14.2"

#pcre
files=()
files=(${files[@]} "https://download.cdn.pupuapp.cn/setups/sdk2.0/pcre-$pcre.tar.gz")
files=(${files[@]} "https://download.cdn.pupuapp.cn/setups/sdk2.0/openssl-$openssl.tar.gz")
files=(${files[@]} "https://download.cdn.pupuapp.cn/setups/sdk2.0/zlib-$zlib.tar.gz")
files=(${files[@]} "https://download.cdn.pupuapp.cn/setups/sdk2.0/nginx-$nginx.tar.gz")
libs=$( download files[@] )

cd $DOWNLOAD/nginx-$nginx
./configure --prefix=$PREFIX/nginx --user=$USER --group=$USER \
	--with-pcre=$DOWNLOAD/pcre-$pcre \
	--with-openssl=$DOWNLOAD/openssl-$openssl \
	--with-zlib=$DOWNLOAD/zlib-$zlib \
	--with-http_sub_module \
	--with-http_v2_module \
	--with-http_gzip_static_module \
	--with-http_stub_status_module --with-http_ssl_module > $DOWNLOAD/nginx.log

make >> $DOWNLOAD/nginx.log
make install >> $DOWNLOAD/nginx.log

ln $PREFIX/nginx/sbin/nginx /sbin/nginx -sf


mkdir $PREFIX/nginx/conf/67
sed -r "s|#NAME#|$NAME|g" $_PWD/conf/nginx.conf > $PREFIX/nginx/conf/nginx.conf
if [ ! -f /www/67/core/cache/deployed ]; then
	sed -r "s|#NAME#|$NAME|g" $_PWD/conf/admin_67.conf > $PREFIX/nginx/conf/67/admin.conf
fi
sed -r "s|#NAME#|$NAME|g" $_PWD/conf/67.conf > $PREFIX/nginx/conf/67/67.conf
rsync -a $_PWD/conf/mime.types $PREFIX/nginx/conf/
