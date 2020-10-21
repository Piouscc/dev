#!/bin/sh

. $(pwd)/include.sh

path=mysql

useradd mysql

VER="mariadb-10.3.12"

rm -rf $DOWNLOAD/$VER

files=()
files=(${files[@]} "https://download.cdn.pupuapp.cn/setups/sdk2.0/$VER.tar.gz")

download files[@]

yum install -y libaio libaio-devel lsof which scons check-devel openssl-devel

cd $DOWNLOAD/$VER
mkdir -p $PREFIX/$path
cmake \
	-DCMAKE_BUILD_TYPE=Release \
	-DWITH_EMBEDDED_SERVER=OFF \
	-DCMAKE_INSTALL_PREFIX:PATH=$PREFIX/$path \
	-DDEFAULT_CHARSET=utf8 \
	-DWITH_EXTRA_CHARSETS:STRING=complex \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DWITH_READLINE=1 \
	-DENABLED_LOCAL_INFILE=1 \
	-DINSTALL_UNIX_ADDRDIR=/tmp/mariadb.sock \
	-DMYSQL_USER=mysql > $DOWNLOAD/mysql.log

make install >> $DOWNLOAD/mysql.log

prefix=/data/mysql
datadir=$prefix/data
binlogdir=$prefix/binlog
relaylogdir=$prefix/relaylog
mkdir -p $prefix/{relaylog,binlog}
chown mysql:mysql $prefix/{relaylog,binlog}

cp $_PWD/conf/my.cnf $PREFIX/$path

sed -r "s|#NAME#|$NAME|g" $_PWD/conf/my.cnf | \
	sed -r "s|#datadir#|$datadir|g"| \
	sed -r "s|#binlogdir#|$binlogdir|g"| \
	sed -r "s|#relaylogdir#|$relaylogdir|g"| \
	sed -r "s|#basedir#|$PREFIX/$path|g" > $PREFIX/mysql/my.cnf

$PREFIX/$path/scripts/mysql_install_db --basedir=$PREFIX/$path --user=mysql --datadir=$datadir --defaults-file=$PREFIX/$path/my.cnf

cp support-files/mysql.server $PREFIX/$path/mysql.server
chmod a+x $PREFIX/$path/mysql.server

$PREFIX/$path/mysql.server start
