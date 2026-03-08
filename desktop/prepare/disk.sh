#!/usr/bin/env bash

. params.sh
. $ldir/script/show.sh

case "$1" in

	create)
		[ -f "$oimg" ] && show_confirm "Ya existe" && sudo rm -rf $oimg
		dd if=/dev/null of=$oimg bs=1M seek=1024 &&\
		sudo mkfs.ext4 -F $oimg
	;;
	
	export)
		umount $2
		dd if="$oimg" of=$2 bs=4M status=progress
	;;
	
	mount)

		say "Montando"
		sudo umount $odir/tmp
		sudo umount $odir
		
		saydir $oimg
		sudo mount -v -t ext4 -o loop $oimg $odir &&\
		sudo chown $busr $odir
		
		cd $odir
		
		mkdir -pv tmp
		sudo mount -vt tmpfs tmpfs tmp
		sudo chown $busr tmp
		
	;;
	umount)
		say "Desmontando" "" "$odir"
		sudo umount $odir/tmp
		sudo umount $odir
	;;
	
esac
