#!/usr/bin/env bash

cdir=$(realpath ../../)
ldir=$cdir/library
tdir=/tmp/club
bdir=/tmp/club/build
sdir=/tmp/club/src
gdir=/tmp/club/log
rdir=/var/club/log
vdir=/var/club/log
otar=x86_64-club-linux-gnu
otar32=i686-club-linux-gnu
odir=/
guide="64"
item="${1:-}" 
arg0="${2:-}"
src="$item" 

clear

export lc_all=posix \
config_site=$odir/usr/share/config.site \
jobs=6 \

r="oa --prefix=/usr" 
cx="cf --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static"
rx="$r --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static"
rxs="$r --prefix=/usr --sysconfdir=/etc --localstatedir=/var "
ru="$r --prefix=/usr"
rud="$ru --disable-static"
mu="mes --prefix=/usr"
mu32="mes32 --prefix=/usr"
mur="$mu --prefix=/usr"


