#!/usr/bin/env bash

guide="desktop"
bdir="/tmp/club/build"
tdir=/tmp/club
cdir=$(realpath ../../)
ldir=$cdir/library
odir=$(realpath ../mount)
oimg=$(realpath ../sys.img)
kimg=$ldir/kernel/linux-club-desktop-6.19

busr=marc
mia=""
chapter="${1:-}"
item="${2:-}" 
arg0="${3:-}"
src="$item" 
clear

