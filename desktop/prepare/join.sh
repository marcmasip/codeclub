#!/usr/bin/env bash

. params.sh
. $ldir/script/show.sh

cd "$odir" &&\
mkdir -pv proc tmp sys run dev root/club/desktop root/club/library
sudo mount --bind /dev dev/
sudo mount -vt devpts devpts -o gid=5,mode=0620 "$odir/dev/pts"
sudo mount -vt proc proc proc
sudo mount -vt sysfs sysfs sys
sudo mount -vt tmpfs tmpfs run
sudo mount -vt tmpfs tmpfs tmp

sudo mkdir -p tmp/club/{build,src}
sudo mkdir -p var/club/log

sudo mount --bind "$cdir/library" root/club/library
sudo mount --bind "$cdir/desktop" root/club/desktop

say "join: entrando en nuevo entorno"

sudo chroot "$odir" /usr/bin/env -i \
	HOME=/root \
	PS1='(desktop prepare chroot) \u:\w\$ ' \
	PATH=/usr/bin:/usr/sbin:/bin \
	makeflags="-j4" \
	testsuiteflags="-j4" \
	bash --login 

cd "$odir"
sudo mountpoint -q "$odir/dev/shm" && sudo umount "$odir/dev/shm"
sudo umount "$odir/dev/pts"
sudo umount "$odir"/{sys,proc,run,dev}
sudo umount -r tmp root/club/library root/club/desktop

say "join: fin"
