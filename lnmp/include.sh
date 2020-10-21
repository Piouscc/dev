#!/bin/sh

NAME=67_serv
_PWD=$(pwd)
PREFIX=/opt/$NAME
LIB=/opt/$NAME/lib
DOWNLOAD=$_PWD/download
LOG=/var/$NAME/log
WWW=/www
USER=www
TMP=/tmp/$NAME



download(){
	local files=("${!1}")
	ret=()

	for file in ${files[@]}; do
		base=$(basename $file)

		tmp=${base##*\?}
		base=$(basename $base "?$tmp")
		dfile=$DOWNLOAD/$base
		if ! [ -s $dfile ]; then
			wget "$file" --directory-prefix=$DOWNLOAD --no-check-certificate
			if ! [ -s $dfile ]; then
				echo "Downloading $file failed!!!"
				exit 0
			fi
		fi
		
		cd $DOWNLOAD
		local path=$DOWNLOAD/$(basename $base .tar.gz)
		rm -rf $path
		tar -zxf $dfile
		
		ret=(${ret[@]} $path)
	done

	#return
	echo ${ret[@]}
}
