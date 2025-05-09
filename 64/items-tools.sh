# Base components setup

# Shortcuts


MIA="DESTDIR=$ODIR"
rt="OA --prefix=$ODIR/tools "
r="OA --prefix=/usr "
TBU=x86_64-pc-linux-gnu
rhb="OA --prefix=/usr --host=$OTAR --build=$TBU"
rchb="CA --prefix=/usr --host=$OTAR --build=$TBU"
# Item plans


case "$ITEM" in


"create-disk")
	[ -f "$OIMG" ] && CONFIRM "Ya existe" && sudo rm -rf $OIMG
	dd if=/dev/null of=$OIMG bs=1M seek=5240 &&\
	sudo mkfs.ext4 -F $OIMG
;;

"mount")
	sudo umount $ODIR/tmp
	sudo umount $ODIR
	sudo mount -t ext4 -o loop $OIMG $ODIR &&\

	sudo chown $BUILDU $ODIR
	
	cd $ODIR
	
	#~mkdir -pv tmp
	#sudo mount -vt tmpfs tmpfs tmp
	#sudo chown $BUILDU tmp
	
;;
"umount")
	sudo umount $ODIR/tmp
	sudo umount $ODIR
	
;;

"create-files")
	cd $ODIR &&\
	mkdir -pv 	$ODIR/{etc,var,tmp} \
				$ODIR/usr/{bin,lib,lib32,sbin} \
				$ODIR/var/club/{log} \
		
	for i in bin lib lib32 sbin; do
	  ln -sv usr/$i $i
	done
	
	mkdir -pv $ODIR/tools
;;


"binutils")
	MIA=""
	$rt --disable-nls       \
	--with-sysroot=$ODIR \
	--target=$OTAR \
	 --enable-gprofng=no \
	 --disable-werror    \
	 --enable-new-dtags  \
	 --enable-default-hash-style=gnu 
;;

"gcc1")
	MIA=""
	SRC=gcc
   	O mpfr && O gmp &&	O mpc && O gcc
	mv -v $SDIR/mpfr $SDIR/gmp $SDIR/mpc $SDIR/gcc &&\

	cd $SDIR/gcc &&\
	sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64 &&\
	
	sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h &&\

	WBD &&\

	CA --prefix=$ODIR/tools --with-sysroot=$ODIR                            \
    --with-newlib                                  \
    --target=$OTAR \
    --with-glibc-version=2.41   \
    --without-headers                              \
    --enable-default-pie                           \
    --enable-default-ssp                           \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-shared                               \
    --enable-multiarch  \
    --enable-multilib --with-multilib-list=m64,m32 \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++  &&\
     cd $SDIR/gcc && cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
	`dirname $($ODIR/tools/bin/$OTAR-gcc -print-libgcc-file-name)`/include/limits.h 
;; 

"kernel-config")
	mkdir $BDIR/linux64 ; cd $BDIR/linux64 &&\
	cp $LDIR/linux-club-conf/.config $BDIR/linux64 && \
	make -C $LDIR/linux-club O=$BDIR/linux64 menuconfig
;;	

"kernel-headers")
	mkdir $BDIR/linux64 ; cd $BDIR/linux64 &&\
	make C=$LDIR/linux-club O=$BDIR/linux64 ARCH=x86_64 headers &&\
	find $BDIR/linux64/usr/include -type f ! -name '*.h' -delete &&\
	cp -rv $BDIR/linux64/usr/include $ODIR/usr/include  
;;

"kernel")
	mkdir $BDIR/linux64 ; cd $BDIR/linux64 &&\
	make C=$LDIR/linux-club O=$BDIR/linux64 ARCH=x86_64 bzImage &&\
	cp arch/x86/boot/bzImage $ODIR/../kernel
;;
"kernel-work")
	mkdir $BDIR/linux64 ; cd $BDIR/linux64 &&\
	make C=$LDIR/linux-club O=$BDIR/linux64 ARCH=x86_64 bzImage &&\
	cp arch/x86/boot/bzImage $ODIR/../kernel-work
;;






"glibc")
	ln -sfv ../lib/ld-linux-x86-64.so.2 $ODIR/lib64
	ln -sfv ../lib/ld-linux-x86-64.so.2 $ODIR/lib64/ld-lsb-x86-64.so.3
	MIA="DESTDIR=$ODIR"
	O &&\
	echo "rootsbindir=/usr/sbin" > configparms &&\
	WBD &&\
	CA --prefix=/usr --host=$OTAR \
	 --enable-kernel=5.4                \
	 --with-headers=$ODIR/usr/include \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib &&\
    sed '/RTLDLIST=/s@/usr@@g' -i $ODIR/usr/bin/ldd 
    
;;

"glibc32")
	SRC=glibc
	O && WBD && BD &&\
	MIA="DESTDIR=$PWD/DESTDIR"
	CC="$OTAR-gcc -m32" 	\
	CXX="$OTAR-g++ -m32" \
	CA --prefix=/usr                      \
      --host=$OTAR32                  \
      --build=$TBU \
      --enable-kernel=5.4                 \
      --with-headers=$ODIR/usr/include    \
      --disable-nscd                     \
      --libdir=/usr/lib32                \
      --libexecdir=/usr/lib32            \
      libc_cv_slibdir=/usr/lib32 &&\
      cp -a DESTDIR/usr/lib32 $ODIR/usr/ &&\
	  install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-32.h $ODIR/usr/include/gnu/ &&\
	  ln -svf ../lib32/ld-linux.so.2 $ODIR/lib/ld-linux.so.2
    
;;

"libstdcpp")
	MIA="DESTDIR=$ODIR"
	O gcc && WBD && BD &&\
	$SDIR/gcc/libstdc++-v3/configure --prefix=/usr                   \
     --enable-multilib              \
     --host=$OTAR \
     --build=$($SDIR/gcc/config.guess) \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$OTAR/include/c++/14.2.0 && make && make DESTDIR=$ODIR install &&\
	rm -v $ODIR/usr/lib/lib{stdc++{,exp,fs},supc++}.la &&\
	
	
    DI gcc
;;

"m4") $r --host=$OTAR --build=$(build-aux/config.guess) ;;


"ncurses")
	tdir="$BDIR/${SRC}_TEMP"
	MIA="DESTDIR=$ODIR TIC_PATH=$tdir/progs/tic" 
	O && WBD && CF && make -C include && make -C progs tic &&\
	
	mv $BDIR/$SRC $tdir &&\
	CA --build=$TBU \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            --enable-widec&&\
     cd $ODIR/usr/lib && ln -sfv libncursesw.so.6 libncurses.so &&\
	 sed -e 's/^#if.*XOPEN.*$/#if 1/' -i $ODIR/usr/include/curses.h &&\
	 rm -rf $tdir
;;

"bash")	
	
	$rhb --without-bash-malloc bash_cv_strtold_broken=no \
	&& cd $ODIR/bin && ln -sfv bash sh ;;

"coreutils") $rhb --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime
;;
"diffutils") $rhb gl_cv_func_strcasecmp_works=y ;;
"file")
	O && autoreconf -i && WBD &&
	CA --prefix=/usr  --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib 
   
    WBD no &&\
    CF $CFPU --build=$TBU &&\
    make FILE_COMPILE=$BDIR/file/src/file &&\
    MI &&\
    rm -v $ODIR/usr/lib/libmagic.la
;;
"findutils")$rhb  --localstatedir=/var/lib/locate ;;
"make")	$rhb  --without-guile ;;
"xz")  $rhb  --disable-static ;;

"zstd") 
	O
	mkdir $BDIR/zstd;cd $SDIR/zstd &&
	make BUILD_DIR=$BDIR/zstd &&\
	make DESTDIR=$ODIR prefix=/usr install 
;;	
"zlib")	$r ;;
"gawk")
	O && BD && sed -i 's/extras//' Makefile.in && $rchb
;;

"binutils2")
	SRC="binutils" &&\
	WBD && BD &&\
	$rhb --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no       \
    --disable-werror           \
    --enable-64-bit-bfd        \
    --enable-new-dtags         \
    --enable-default-hash-style=gnu &&\
    rm -v $ODIR/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}
;;

"gcc2")
	SRC="gcc"
	O mpfr 
	O gmp 
	O mpc 
	O gcc
	mv $SDIR/mpc $SDIR/gmp $SDIR/mpfr $SDIR/gcc &&\
	
	sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64 &&\
    
    sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h &&\
    
    sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in &&\
    
	mlist=m64,m32 &&\
	WBD &&\
    CA --prefix=/usr \
    LDFLAGS_FOR_TARGET=-L$PWD/$OTAR/libgcc      \
    --with-build-sysroot=$ODIR                      \
    --enable-default-pie                           \
    --enable-default-ssp                           \
    --disable-nls                                  \
    --enable-multilib --with-multilib-list=$mlist  \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libsanitizer                         \
    --disable-libssp                               \
    --disable-libvtv                               \
    --enable-languages=c,c++ &&\
    
    cd $ODIR/usr/bin && ln -sfv gcc cc 
;;


*) $rhb ;;


esac
