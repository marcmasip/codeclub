#!/usr/bin/env bash

guide="server"
bdir="/tmp/club/build"
tdir=/tmp/club
cdir=$(realpath ../)
odir=$(realpath mount)
ldir=$cdir/library
oimg=sys.img
dimg=data.img
#kimg=/tmp/club/build/linux-club-desktop/arch/x86/boot/bzImage
#kimg=$ldir/kernel/x86_64-linux-emojiclub-desktop
#kimg=/tmp/club/build/linux-club-server/arch/x86/boot/bzImage
#kimg=/tmp/club/build/linux-club-desktop/arch/x86/boot/bzImage
kimg=$ldir/kernel/linux-club-server
busr=marc
mia=""
chapter="${1:-}"
item="${2:-}" 
arg0="${3:-}"
src="$item" 
clear


