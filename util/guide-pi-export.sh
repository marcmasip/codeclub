

export PATH=$PATH:$PI_XDIR/bin

case "$ITEM" in


"fs")
	cd $PI_STDIR_FS &&\
	find . | cpio -o -H newc | gzip > $PI_STDIR/initramfs.gz
;;

"sd-fs")
	
	

;;
	
"test")


;;

esac

