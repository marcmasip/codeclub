



case "$ITEM" in


"binutils")
	OA --prefix=$PI_XDIR --target=$OTAR --disable-nls
;;

"gcc")
	CFLAGS=""
	LDFLAGS=""
   	O mpfr && O gmp &&	O mpc && O gcc
	mv -v $SDIR/mpfr $SDIR/gmp $SDIR/mpc $SDIR/gcc &&\
	WBD && \
	CA --prefix=$PI_XDIR \
		--target=$OTAR \
		--with-sysroot=$PI_XDIR/sysroot \
        --with-newlib \
        --without-headers \
        --enable-default-pie      \
		--enable-default-ssp      \
        --disable-nls \
        --disable-shared \
        --disable-multilib \
        --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx \
        --enable-languages=c,c++  &&\
     cd $SDIR/gcc && cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
	`dirname $($PI_XDIR/bin/$OTAR-gcc -print-libgcc-file-name)`/include/limits.h 
;;  

"libstdcpp")
	SRC=gcc
	O gcc && WBD &&\
	ln -sf $SDIR/gcc/libstdc++-v3 $SDIR/libstdcpp 
	CA --build=$OTAR  			\
    --target=$OTAR \
    --prefix=$PI_XDIR         \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=$PI_XDIR/sysroot/usr/include/c++/14.2.0  &&\

    DI gcc
;;

"kernel-clean")
	cd $LDIR/linux-club-pi && make mrproper
;;

"kernel-config")
	mkdir $BDIR/linuxPI ; cd $BDIR/linuxPI &&\
	cp $LDIR/linux-club-pi-conf/.config $BDIR/linuxPI && \
	make -C $LDIR/linux-club-pi O=$BDIR/linuxPI menuconfig
;;	

"kernel-headers")
	mkdir $BDIR/linuxPI ; cd $LDIR/linux-club-pi &&\
	make C=$LDIR/linux-club-pi O=$BDIR/linuxPI ARCH=arm CROSS_COMPILE=$PI_XDIR/bin/$OTAR- headers &&\
	find $BDIR/linuxPI/usr/include -type f ! -name '*.h' -delete &&\
	mkdir -p $PI_XDIR/sysroot/usr/include 
	cp -rv $BDIR/linuxPI/usr/include/* $PI_XDIR/sysroot/usr/include &&
	cp -rv $PI_XDIR/sysroot/usr/include/asm-generic/* $PI_XDIR/sysroot/usr/include/asm

;;

"kernel")
	mkdir $BDIR/linuxPI ; cd $LDIR/linux-club-pi &&\
	make -j6 C=$LDIR/linux-club-pi O=$BDIR/linuxPI ARCH=arm CROSS_COMPILE=$PI_XDIR/bin/$OTAR- zImage dtbs &&\
	cd $BDIR/linuxPI &&\
	sudo cp -v arch/arm/boot/zImage $PI_STDIR/kernel-club-pi.zimage &&\
	mkdir -p $PI_STDIR/overlays ;
	cp -v arch/arm/boot/dts/broadcom/*.dtb $PI_STDIR &&\
	cp -v arch/arm/boot/dts/overlays/*.dtb* $PI_STDIR/overlays/
;;


  






esac
