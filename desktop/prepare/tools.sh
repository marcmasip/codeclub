#!/usr/bin/env bash
# Welcome to codeclub
. conf.sh
. $ldir/script/show.sh
. $cdir/desktop/install/macro.sh

PATH=$odir/tools/bin:$PATH

mia="DESTDIR=$odir"

rt="oa --prefix=$odir/tools "

#regular
r="oa --prefix=/usr "
tbu=x86_64-club-linux-gnu
rhb="oa --prefix=/usr --host=$otar --build=$tbu"
rchb="ca --prefix=/usr --host=$otar --build=$tbu"

ins_kconfig(){
	mkdir $bdir/linux64 ; cd $bdir/linux64 &&\
	cp $ldir/etc/.config-linux-club-desktop $bdir/linux64 && \
	make -C $ldir/linux O=$bdir/linux64 menuconfig
}

ins_kheaders(){
	mkdir $bdir/linux64 ; cd $bdir/linux64 &&\
	make C=$ldir/linux O=$bdir/linux64 ARCH=x86_64 headers &&\
	find $bdir/linux64/usr/include -type f ! -name '*.h' -delete &&\
	mkdir -pv $odir/usr/include &&\
	cp -rv $bdir/linux64/usr/include/* $odir/usr/include  
}

ins_tools(){
	cd $odir &&\
	mkdir -pv tools/{lib,bin} 
	cd $odir/tools &&\
	ln -s lib lib64
	return $?
}

ins_binutils(){
  at_gnu 2.44 &&\
  mia="" $rt --disable-nls       \
	--with-sysroot=$odir \
	--target=$otar \
	 --enable-gprofng=no \
	 --disable-werror    \
	 --enable-new-dtags  \
	 --enable-default-hash-style=gnu 
}

at_gcc(){
	ato gnu gmp 6.3.0  &&\
	ato gnu mpfr 4.2.0  &&\
	ato gnu mpc 1.3.1 &&\
	ato https://ftp.rediris.es/mirror/GNU/gcc/gcc-15.2.0/gcc-15.2.0.tar.xz &&\
	mv -v $sdir/{mpfr,gmp,mpc} $sdir/gcc  && cd $sdir/gcc

	return $?	
}

ins_gcc1(){
	
	mia=""
	src=gcc
	at_gcc &&\

	sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64 &&\
	sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h &&\

	wbd &&\

	CXXCPP=/usr/bin/cpp ca --prefix=$odir/tools --with-sysroot=$odir                            \
    --with-newlib                                  \
    --target=$otar \
    --with-glibc-version=2.42   \
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
     cd $sdir/gcc && cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
	`dirname $($odir/tools/bin/$otar-gcc -print-libgcc-file-name)`/include/limits.h 
	
	return $?	
}

ins_glibc(){
	ln -sfv ../lib/ld-linux-x86-64.so.2 $odir/lib64 &&\
	ln -sfv ../lib/ld-linux-x86-64.so.2 $odir/lib64/ld-lsb-x86-64.so.3 &&\
	at gnu 2.42 &&\
	o &&\
	echo "rootsbindir=/usr/sbin" > configparms &&\
	wbd &&\
	ca --prefix=/usr --host=$otar \
	 --enable-kernel=5.4                \
	 --with-headers=$odir/usr/include \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib &&\
    sed '/RTLDLIST=/s@/usr@@g' -i $odir/usr/bin/ldd 
	
    return $?
}
ins_glibc32(){
	
	src=glibc
	at gnu 2.42 &&\
	o && wbd && bd &&\
	echo "rootsbindir=/usr/sbin" > configparms &&\
	mia="DESTDIR=$PWD/DESTDIR"
	CC="$otar-gcc -m32" 	\
	CXX="$otar-g++ -m32" \
	 ca --prefix=/usr                      \
      --host=$otar32                  \
      --build=$tbu \
      --enable-kernel=5.4                 \
      --with-headers=$odir/usr/include    \
      --disable-nscd                     \
      --libdir=/usr/lib32                \
      --libexecdir=/usr/lib32            \
      libc_cv_slibdir=/usr/lib32 &&\
      cp -a DESTDIR/usr/lib32 $odir/usr/ &&\
	  install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-32.h $odir/usr/include/gnu/ &&\
	  ln -svf ../lib32/ld-linux.so.2 $odir/lib/ld-linux.so.2
}

ins_stdcpp(){
	src="gcc"
	at https://ftp.rediris.es/mirror/GNU/gcc/gcc-15.2.0/gcc-15.2.0.tar.xz &&\
	o && wbd && bd &&\
	$sdir/gcc/libstdc++-v3/configure --prefix=/usr                   \
     --enable-multilib              \
     --host=$otar \
     --build=$tbu \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$otar/include/c++/15.2.0 &&\
    mo && mi && \
	rm -v $odir/usr/lib/lib{stdc++{,exp,fs},supc++}.la 
    
    return $?
}


ins_m4(){
	at gnu 1.4.20 &&\
	PATH=$odir/tools/bin:$PATH $r --host=$otar --build=$tbu
    return $?
}

ins_ncurses(){
	at gnu 6.5 &&\
	o && mkdir build
	pushd build &&\
	  ../configure --prefix=$odir/tools AWK=gawk &&\
	  make -C include &&\
	  make -C progs tic &&\
	  install progs/tic $odir/tools/bin &&\
	popd &&\
	
	
	ca --build=$(./config.guess)   \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            --enable-widec&&\
     cd $odir/usr/lib && ln -sfv libncursesw.so.6 libncurses.so &&\
	 sed -e 's/^#if.*XOPEN.*$/#if 1/' -i $odir/usr/include/curses.h &&\
	bd &&\
	make distclean &&\
	CC="$otar-gcc -m32"              \
	CFLAGS=" -std=gnu17" \
CXX="$otar-g++ -m32"             \
./configure --prefix=/usr           \
            --host=$otar32       \
            --build=$tbu    \
            --libdir=/usr/lib32     \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-normal        \
            --with-cxx-shared       \
            --without-debug         \
            --without-ada           \
            --disable-stripping &&
            make && make DESTDIR=$PWD/DESTDIR TIC_PATH=$(pwd)/build/progs/tic install &&\
ln -sv libncursesw.so DESTDIR/usr/lib32/libncurses.so &&\
cp -Rv DESTDIR/usr/lib32/* $odir/usr/lib32 &&\
rm -rf DESTDIR
            
	 
	 return $?
}
ins_bash(){
	at gnu 5.3
	$rhb --without-bash-malloc bash_cv_strtold_broken=no \
	&& cd $odir/bin && ln -sfv bash sh 
	
	return $?
	
}

ins_coreutils(){
	at gnu 9.5 &&\
	$rhb --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime
    return $?
}

ins_diffutils(){
	at gnu diffutils 3.10 tar.xz  &&\
	$rhb gl_cv_func_strcasecmp_works=y 
    return $?
}
ins_file(){
	at http://ftp.astron.com/pub/file/file-5.46.tar.gz   &&\
	o && autoreconf -i && wbd &&
	ca --prefix=/usr  --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib 
   
    wbd no &&\
    cf --prefix=/usr --build=$tbu &&\
    make FILE_COMPILE=$bdir/file/src/file &&\
    mi &&\
    rm -v $odir/usr/lib/libmagic.la

    return $?
}
ins_findutils(){
	at gnu findutils 4.10.0 tar.xz &&\
	$rhb  --localstatedir=/var/lib/locate 
	return $?
}

ins_gawk(){
	at gnu 5.3.2 &&\
	o && bd && sed -i 's/extras//' Makefile.in && $rchb
	return $?
}
ins_grep(){
	at gnu 3.12 && $rhb
	return $?
}
ins_gzip(){
	at gnu 1.13 && $rhb
	return $?
}
ins_make(){
	at gnu 4.4.1 && $rhb  --without-guile
	return $?
}
ins_patch(){
	at gnu 2.7.6 && $rhb 
	return $?
}
ins_sed(){
	at gnu 4.9 && $rhb 
	return $?
}
ins_tar(){
	at gnu 1.35 && $rhb 
	return $?
}
ins_xz(){
	at  https://github.com/tukaani-project/xz/releases/download/v5.6.2/xz-5.6.2.tar.gz && $rhb 
	return $?
}

ins_zstd(){
	at https://github.com/facebook/zstd/releases/download/v1.5.6/zstd-1.5.6.tar.gz &&\
	o &&\
	mkdir $bdir/zstd;cd $sdir/zstd &&
	make BUILD_DIR=$bdir/zstd &&\
	make DESTDIR=$odir prefix=/usr install 
	
	return $?
}

ins_zlib(){
	at https://www.zlib.net/zlib-1.3.1.tar.gz && $r
	return $?
}

ins_binutils2(){
	src="binutils" &&\
	at gnu 2.44 &&\
	
	wbd && bd &&\
	 $rhb --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no       \
    --disable-werror           \
    --enable-64-bit-bfd        \
    --enable-new-dtags         \
    --enable-default-hash-style=gnu &&\
    rm -v $odir/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}
    
	return $?
}

mlist=m64,m32
ins_gcc2(){
	
	src="gcc"
	at_gcc &&\
	
	sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64 &&\
    
    sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h &&\
    
    sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in &&\

	wbd && bd &&\
    $rchb --target=$otar \
    --with-build-sysroot=$odir                      \
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
    --enable-languages=c,c++ \
     LDFLAGS_FOR_TARGET=-L$(pwd)/$otar/libgcc &&\
    
    cd $odir/usr/bin && ln -sfv gcc cc 
    
	return $?
}

run_item
