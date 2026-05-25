#!/usr/bin/env bash

guide="desktop"
bdir="/tmp/club/build"
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

odir=$(realpath ../mount )
oimg=$(realpath ../sys.img)
kimg=$ldir/kernel/linux-club-desktop-6.19

busr=marc
mia=""
guide="64"
item="${1:-}" 
arg0="${2:-}"
argall="$@"
chapter=$0
src="$item" 
clear

