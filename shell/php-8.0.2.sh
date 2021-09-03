#!/bin/bash

yum install -y unixODBC-devel cmake3 sqlite-devel wget oniguruma-devel 
#libzip PHP7.3后需要libzip-0.11以上版本
yum remove -y libzip

DOWNLOAD_PATH=/usr/local/src
cd $DOWNLOAD_PATH

#libzip
ver=1.5.2
cd $DOWNLOAD_PATH/
wget https://download.cdn.pupuapp.cn/setups/sdk2.0/libzip-$ver.tar.gz
tar -xf $DOWNLOAD_PATH/libzip-$ver.tar.gz
cd $DOWNLOAD_PATH/libzip-$ver
mkdir build && cd build
cmake3 .. 
make > /dev/null
make install > /dev/null

#libmcrypt
cd $DOWNLOAD_PATH/ 
wget https://download.cdn.pupuapp.cn/setups/sdk2.0/libmcrypt-2.5.8.tar.gz
if [[ $? -ne 0 ]];then
    wget https://download.cdn.pupuapp.cn/setups/sdk2.0/libmcrypt-2.5.8.tar.gz
    if [[ $? -ne 0 ]];then
        echo "libmcrypt_pg download error"
    fi
fi
tar -xf libmcrypt-2.5.8.tar.gz && cd $DOWNLOAD_PATH/libmcrypt-2.5.8/libltdl
./configure --enable-ltdl-install > /dev/null
echo "configuring libltdl"
make > /dev/null
make install > /dev/null

#libiconv
cd $DOWNLOAD_PATH/ 
wget https://download.cdn.pupuapp.cn/setups/sdk2.0/libiconv-1.15.tar.gz
if [[ $? -ne 0 ]];then
    wget https://download.cdn.pupuapp.cn/setups/sdk2.0/libmcrypt-2.5.8.tar.gz
    if [[ $? -ne 0 ]];then
        echo "libmcrypt_pg download error"
    fi
fi
tar -xf libiconv-1.15.tar.gz && cd $DOWNLOAD_PATH/libiconv-1.15
./configure --prefix=/usr/local/libiconv && make && make install

f=(/usr/lib64/libldap*)
for l in "${f[@]}"; do
	ln -sf $l /usr/lib/$(basename $l)
done

PHP_VERSION=php-8.0.2

file="https://www.php.net/distributions/$PHP_VERSION.tar.gz"
if ! [ -s "$DOWNLOAD_PATH/$PHP_VERSION.tar.gz" ]; then
	wget $file --directory-prefix=$DOWNLOAD_PATH
	if ! [ -s "$DOWNLOAD_PATH/$PHP_VERSION.tar.gz" ]; then
		echo "Downloading $file failed!!!"
		exit
	fi
fi

PHP_SRC_PATH=$DOWNLOAD_PATH/$PHP_VERSION
DIR=php-8.0
PREFIX=/opt/67_serv
PHP_PATH=$PREFIX/$DIR

rm -rf $PHP_SRC_PATH

cd $DOWNLOAD_PATH
tar -zxf $DOWNLOAD_PATH/$PHP_VERSION.tar.gz

cd $PHP_SRC_PATH

echo '/usr/local/lib64' >> /etc/ld.so.conf
echo '/usr/lib' >> /etc/ld.so.conf
echo '/usr/lib64' >> /etc/ld.so.conf

ldconfig
./configure --prefix=$PHP_PATH \
	--with-config-file-path=$PHP_PATH/etc \
	--enable-fastcgi --enable-fpm \
	--with-mysqli=mysqlnd \
	--enable-pdo --with-pdo-mysql=mysqlnd \
	--with-iconv=/usr/local/libiconv  \
	--with-iconv-dir \
	--with-zlib-dir \
	--with-mcrypt \
	--with-openssl \
	--with-openssl-dir \
	--with-gd \
	--with-freetype-dir \
	--with-jpeg-dir \
	--with-png-dir \
	--with-curl \
	--with-curlwrappers \
	--with-libxml-dir=/usr \
	--with-ldap --with-ldap-sasl \
	--enable-bcmath \
	--enable-soap \
	--enable-ftp \
	--enable-force-cgi-redirect \
	--enable-mbstring --enable-zip \
	--enable-sysvsem --enable-inline-optimization \
	--enable-pcntl --enable-bcmath \
	--with-gettext \
	--disable-debug --disable-rpath --enable-sockets --quiet

[ "$?" -ne 0 ] && echo 'configuring php failed' && exit
make ZEND_EXTRA_LIBS='-liconv -llber' --quiet
make install

cp sapi/fpm/init.d.php-fpm $PHP_PATH/fpm
chmod a+x $PHP_PATH/fpm
mv /bin/php /bin/php.bak
ln -sf $PHP_PATH/bin/php /bin/php
ln -sf $PHP_PATH/fpm /sbin/fpm

#igbinary
ver=3.0.1
cd $DOWNLOAD_PATH/
rm -rf igbinary-$ver.tar.gz igbinary-$ver
wget https://download.cdn.pupuapp.cn/setups/sdk2.0/igbinary-$ver.tar.gz
tar -xf $DOWNLOAD_PATH/igbinary-$ver.tar.gz
cd $DOWNLOAD_PATH/igbinary-$ver
$PHP_PATH/bin/phpize
./configure --with-php-config=$PHP_PATH/bin/php-config
make > /dev/null
make install > /dev/null

#phpredis
ver=5.1.0
cd $DOWNLOAD_PATH/
rm -rf phpredis-$ver.tar.gz phpredis-$ver
wget https://download.cdn.pupuapp.cn/setups/sdk2.0/phpredis-$ver.tar.gz
tar -xf $DOWNLOAD_PATH/phpredis-$ver.tar.gz

cd $DOWNLOAD_PATH/phpredis-$ver
$PHP_PATH/bin/phpize
./configure --with-php-config=$PHP_PATH/bin/php-config
make > /dev/null
make install > /dev/null


#libevent
ver=2.1.11
cd $DOWNLOAD_PATH/
rm -rf libevent-$ver-stable.tar.gz libevent-$ver-stable
wget https://download.cdn.pupuapp.cn/setups/sdk2.0/libevent-$ver-stable.tar.gz
tar -xvf $DOWNLOAD_PATH/libevent-$ver-stable.tar.gz
cd $DOWNLOAD_PATH/libevent-$ver-stable
./configure
make > /dev/null
make install > /dev/null

#event
ver=3.0.2r1
cd $DOWNLOAD_PATH/
rm -rf event-$ver.tgz event-$ver
#wget https://download.cdn.pupuapp.cn/setups/sdk2.0/event-$ver.tgz
wget https://pecl.php.net/get/event-$ver.tgz
tar -xvf $DOWNLOAD_PATH/event-$ver.tgz
cd $DOWNLOAD_PATH/event-$ver
$PHP_PATH/bin/phpize
./configure --with-php-config=$PHP_PATH/bin/php-config
make > /dev/null
make install > /dev/null
