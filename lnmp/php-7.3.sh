#!/bin/sh


. $(pwd)/include.sh

yum install -y unixODBC-devel cmake3
#libzip PHP7.3后需要libzip-0.11以上版本
yum remove -y libzip

ver=1.5.2
cd $DOWNLOAD/
rm -rf libzip-$ver libzip-$ver.tar.gz
wget https://download.cdn.pupuapp.cn/setups/sdk2.0/libzip-$ver.tar.gz
tar -xf $DOWNLOAD/libzip-$ver.tar.gz
cd $DOWNLOAD/libzip-$ver
mkdir build && cd build
cmake3 .. 
make > /dev/null
make install > /dev/null


files=()
files=(${files[@]} "https://download.cdn.pupuapp.cn/setups/sdk2.0/libmcrypt-2.5.8.tar.gz")
files=(${files[@]} "https://download.cdn.pupuapp.cn/setups/sdk2.0/libiconv-1.15.tar.gz")
#files=(${files[@]} "https://download.cdn.pupuapp.cn/setups/sdk2.0/libmemcached-1.0.18.tar.gz")
libs=$( download files[@] )

for lib in ${libs[@]}; do
	cd $lib
	name=$(basename $lib)
	echo "configuring $name"
	./configure > $DOWNLOAD/$name.log
	[ $? -ne 0 ] && echo -e "-------------------\n configure $name fail" && exit 1
	make >> $DOWNLOAD/$name.log
	[ $? -ne 0 ] && echo -e "-------------------\n make $name fail" && exit 1
	make install >> $DOWNLOAD/$name.log
	[ $? -ne 0 ] && echo -e "-------------------\n install $name fail" && exit 1
	cd $_PWD
done

#mcrypt
cd $DOWNLOAD/libmcrypt-2.5.8/libltdl
./configure --enable-ltdl-install > /dev/null
echo "configuring libltdl"
make > /dev/null
make install > /dev/null
cd $_PWD

f=(/usr/lib64/libldap*)
for l in "${f[@]}"; do
	ln -sf $l /usr/lib/$(basename $l)
done


PHP_VERSION=php-7.3.11

file="https://download.cdn.pupuapp.cn/setups/sdk2.0/$PHP_VERSION.tar.gz"
if ! [ -s "$DOWNLOAD/$PHP_VERSION.tar.gz" ]; then
	wget $file --directory-prefix=$DOWNLOAD
	if ! [ -s "$DOWNLOAD/$PHP_VERSION.tar.gz" ]; then
		echo "Downloading $file failed!!!"
		exit
	fi
fi

PHP_SRC_PATH=$DOWNLOAD/$PHP_VERSION
DIR=php-7.3
PHP_PATH=$PREFIX/$DIR

rm -rf $PHP_SRC_PATH

cd $DOWNLOAD
tar -zxf $DOWNLOAD/$PHP_VERSION.tar.gz

cd $PHP_SRC_PATH

echo '/usr/local/lib64' >> /etc/ld.so.conf
echo '/usr/lib' >> /etc/ld.so.conf
echo '/usr/lib64' >> /etc/ld.so.conf

ldconfig
#sed -i 's/"-lgd  $LIBS"/"-lgd -liconv $LIBS"/g' configure
./configure --prefix=$PHP_PATH \
	--with-config-file-path=$PHP_PATH/etc \
	--enable-fastcgi --enable-fpm \
	--with-mysqli=mysqlnd \
	--enable-pdo --with-pdo-mysql=mysqlnd \
	--with-iconv \
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
	#--with-apxs2=$PREFIX/apache/bin/apxs
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
cd $DOWNLOAD/
rm -rf igbinary-$ver.tar.gz igbinary-$ver
wget https://download.cdn.pupuapp.cn/setups/sdk2.0/igbinary-$ver.tar.gz
tar -xf $DOWNLOAD/igbinary-$ver.tar.gz
cd $DOWNLOAD/igbinary-$ver
$PHP_PATH/bin/phpize
./configure --with-php-config=$PHP_PATH/bin/php-config
make > /dev/null
make install > /dev/null

#phpredis
ver=5.1.0
cd $DOWNLOAD/
rm -rf phpredis-$ver.tar.gz phpredis-$ver
wget https://download.cdn.pupuapp.cn/setups/sdk2.0/phpredis-$ver.tar.gz
tar -xf $DOWNLOAD/phpredis-$ver.tar.gz

cd $DOWNLOAD/phpredis-$ver
$PHP_PATH/bin/phpize
./configure --with-php-config=$PHP_PATH/bin/php-config
make > /dev/null
make install > /dev/null

sed -r "s|#NAME#|$NAME|g" $_PWD/conf/php.ini > $PHP_PATH/etc/php.ini
sed -i -r "s|#EXT_DATE#|20180731|g" $PHP_PATH/etc/php.ini
sed -i -r "s|#DIR#|$DIR|g" $PHP_PATH/etc/php.ini
sed -r "s|#NAME#|$NAME|g" $_PWD/conf/php-fpm.conf > $PHP_PATH/etc/php-fpm.conf

#libevent
ver=2.1.11
cd $DOWNLOAD/
rm -rf libevent-$ver-stable.tar.gz libevent-$ver-stable
wget https://download.cdn.pupuapp.cn/setups/sdk2.0/libevent-$ver-stable.tar.gz
tar -xvf $DOWNLOAD/libevent-$ver-stable.tar.gz
cd $DOWNLOAD/libevent-$ver-stable
./configure
make > /dev/null
make install > /dev/null

#event
ver=2.5.3
cd $DOWNLOAD/
rm -rf event-$ver.tgz event-$ver
wget https://download.cdn.pupuapp.cn/setups/sdk2.0/event-$ver.tgz
tar -xvf $DOWNLOAD/event-$ver.tgz
cd $DOWNLOAD/event-$ver
$PHP_PATH/bin/phpize
./configure --with-php-config=$PHP_PATH/bin/php-config
make > /dev/null
make install > /dev/null