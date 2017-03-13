#!/bin/sh
# @(#)wget.sh  1.3 05/05/30 Copyright 2005 J. Schilling
###########################################################################
# Written 2005 by J. Schilling
###########################################################################
# A simulation of wget using ftp
###########################################################################
# Copyright J�rg Schilling. All rights reserved.
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only.
# See the file CDDL.Schily.txt in this distribution or
# http://opensource.org/licenses/cddl1.php for details.
###########################################################################

excod=255

trap 'rm -fr /tmp/.d.$$ ; exit 1' 1 2 15
trap 'rm -fr /tmp/.d.$$ ; exit $excode' 0

if [ $# -lt 1 ]; then
	echo "Usage: wget.sh [-d] URL"
	echo "Options:"
	echo "	-d	Print a listing of the dir part and exit"
	echo
	echo "Only ftp:// type URLs are supported"
	exit 1
fi

dodir=FALSE
if [ ."$1" = .-d ]; then
	dodir=TRUE
	shift
fi
URL="$1"
rest=`echo "$URL" | sed -e 's,^ftp://,,'`
if [ "$URL" = "$rest" ]; then
	echo "Unsupported protocol in" "$URL"
	exit 1
fi

HOST=`echo "$rest" | sed -e 's,/.*,,'`
FILE=`echo "$rest" | sed -e 's,^[^/]*/,,'`
#echo HOST "$HOST"
#echo FILE "$FILE"

DNAME=`echo "$FILE" | sed -e 's,[^/]*$,,;s,/$,,;s,^$,.,'`
FNAME=`echo "$FILE" | sed -e 's,.*/,,'`
#echo DNAME "$DNAME"
#echo FNAME "$FNAME"

mkdir /tmp/.d.$$
cat <<EOF > /tmp/.d.$$/.netrc
machine "$HOST"  login ftp password wget.sh@Makefiles.Schily.build
EOF
chmod 600 /tmp/.d.$$/.netrc

if [ $dodir = TRUE ]; then
	HOME=/tmp/.d.$$ ftp "$HOST" <<EOF
	bin
	passive on
	cd "$DNAME"
	dir
	bye
EOF
excode=$?

else

	HOME=/tmp/.d.$$ ftp "$HOST" <<EOF
	bin
	passive on
	cd "$DNAME"
	dir "$FNAME"
	hash on
	verbose on
	get "$FNAME"
	bye
EOF
excode=$?
fi
