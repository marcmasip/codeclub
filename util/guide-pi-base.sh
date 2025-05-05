




SETX(){
	
	export CHOST=$OTAR \
	CC=/opt/cross/pi/bin/$OTAR-gcc \
	CXX=/opt/cross/pi/bin/$OTAR-g++ \
	AR=/opt/cross/pi/bin/$OTAR-ar \
	RANLIB=/opt/cross/pi/bin/$OTAR-ranlib \
	SYSROOT=$PI_XDIR/sysroo
}

export PATH=$PATH:$PI_XDIR/bin

case "$ITEM" in



"kernel")
	cd $PI_ODIR &&\
	find . | cpio -o -H newc | gzip > $PI_ODIR/../disk/initramfs.gz
;;


"glibc")
	CFLAGS=""
	LDFLAGS=""
	
	O &&\
	WBD &&\
	echo "rootsbindir=$PI_XDIR/sbin" > configparms &&\
    CF --prefix=/usr --host=$OTAR --with-sysroot=$PI_XDIR/sysroot --build=x86_64-pc-linux-gnu --disable-werror --with-headers=$PI_XDIR/sysroot/usr/include --enable-stack-protector=strong --disable-nscd --enable-static-nss libc_cv_slibdir=/lib  &&\
    MO &&\
    sed 's/.*test-installation.*/ #/g' -i $SDIR/$SRC/Makefile &&\
    make DESTDIR=$PI_XDIR/sysroot install
;; 

"glibc-install")
	
	mkdir -p $PI_STDIR_FS/lib ; 
	cp $PI_XDIR/sysroot/lib/{ld-linux-armhf.so.3,libc.so.6,libm.so.6,librt.so.1,libpthread.so.0,libdl.so.2} $PI_STDIR_FS/lib
	
;;


"busybox-config") SRC="busybox"
	O && WBD &&\
	 
	make menuconfig
;;

"busybox")
	SBB=$LDIR/develop/busybox
	WBD && BD &&\
	cp $LDIR/busybox-conf/.config .config &&\
	PATH=$PATH:$PI_XDIR/bin make KBUILD_SRC=$SBB ARCH=arm CROSS_COMPILE=$PI_XDIR/bin/$OTAR- -f $SBB/Makefile &&\
	cp busybox $PI_STDIR_FS/usr/bin/busybox
	
;;

"dropbear")
	MIA="DESTDIR=$PI_XDIR/sysroot"
	OA  --host=$OTAR \
        --enable-static \
        --disable-syslog \
        --prefix=/usr \
        --exec-prefix=/usr \

;;

"libtirpc")
	MIA="DESTDIR=$PI_XDIR/sysroot"
	OA	--host=$OTAR --prefix=/usr \
		--sysconfdir=/etc                               \
		--disable-static                                \
		--disable-gssapi 
;;

"libnsl")
MIA="DESTDIR=$PI_XDIR/sysroot"
OA --host=$OTAR --prefix=/usr \
  --sysconfdir=/etc \
  --disable-static \
  --with-sysroot=$PI_XDIR/sysroot
  
;;

"zlib")
MIA="DESTDIR=$PI_XDIR/sysroot"
SETX && OA --prefix=/usr


           
  
 ;;
 
 "git")
 
	MIA="DESTDIR=$PI_XDIR/sysroot"
	SETX && export ac_cv_fread_reads_directories=no ac_cv_snprintf_returns_bogus=false && OA --build=x86_64-club-linux-gnu  --host=$OTAR --prefix=/usr
 
 ;;
"zstd")
	O && BD && SETX &&\
	make prefix=/usr &&\
	make prefix=$PI_XDIR/sysroot/usr install &&\
	rm -v $PI_XDIR/sysroot/usr/lib/libzstd.a
;;


"libxcrypt")
MIA="DESTDIR=$PI_XDIR/sysroot"
WBD && BD && OA --prefix=/usr --host=$OTAR --enable-hashes=strong,glibc \
	--enable-obsolete-api=no     \
	--disable-failure-tokens

;;

"sshd")

MIA="DESTDIR=$PI_XDIR/sysroot" &&\
CHOST=arm \
CC=/opt/cross/pi/bin/$OTAR-gcc \
CXX=/opt/cross/pi/bin/$OTAR-g++ \
AR=/opt/cross/pi/bin/$OTAR \
RANLIB=/opt/cross/pi/bin/$OTAR \
SYSROOT=$PI_XDIR/sysroot OA --prefix=/usr                            \
			--host=$OTAR \
            --sysconfdir=/etc/ssh                    \
            --with-privsep-path=/var/lib/sshd        \
            --with-default-path=/usr/bin             \
            --with-superuser-path=/usr/sbin:/usr/bin \
            --with-pid-dir=/run                      
           
  
 ;;


"fs")
	
	cd $PI_STDIR_FS &&\
	mkdir -p ./{usr,etc,dev,var}
	mkdir -p usr/{lib,bin}
	ln -s usr/lib lib
	ln -s usr/bin bin

;;
	





esac
