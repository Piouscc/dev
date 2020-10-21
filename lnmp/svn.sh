#!/bin/sh


. $(pwd)/include.sh

mkdir -p /www/67/svn
chown www:www /www/67/svn

cd $_PWD
mkdir -p /data/svn
chown www:www /data/svn
su www -c "svnadmin create /data/svn"
rsync -av $_PWD/conf/svn/ /data/svn/conf/

