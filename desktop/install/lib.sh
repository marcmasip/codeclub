#!/usr/bin/env bash

. conf.sh
. $ldir/script/show.sh
. macro.sh

# Devices
ins_libevdev() {
    at "https://www.freedesktop.org/software/libevdev/libevdev-1.13.4.tar.xz"
    # paquete autotools estandar. o+cf+m
    oa --prefix=/usr --disable-static
    return $?
}
ins_mtdev(){
	at https://bitmath.org/code/mtdev/mtdev-1.1.7.tar.bz2
	return $?
}
ins_libusb(){
	at "https://github.com/libusb/libusb/releases/download/v1.0.29/libusb-1.0.29.tar.bz2" && $r
	return $?
}


# Networking


ins_libssh2(){
	at https://www.libssh2.org/download/libssh2-1.11.1.tar.gz \
		--disable-docker-tests \
        --disable-static
	return $?
}

ins_libconfig(){
	at "https://github.com/hyperrealm/libconfig/archive/refs/tags/v1.8.2.tar.gz" 1.8.2 && o && autoreconf && ca
	return $?
}
ins_uthash(){
	at "https://github.com/troydhanson/uthash/archive/refs/tags/v2.3.0.tar.gz" 2.3.0 && o && cp src/*.h /usr/include
	return $?
}

ins_libccid(){
	src=CCID 
	at "https://github.com/LudovicRousseau/CCID/archive/refs/tags/1.7.1.tar.gz" "1.7.1" "tar.gz" "CCID-1.7.1" && $mur
	return $?
}

ins_pcsc(){
	at "https://github.com/LudovicRousseau/PCSC/archive/refs/tags/2.4.1.tar.gz" "2.4.1" "tar.gz" "PCSC-2.4.1" && $mur -Dlibsystemd=false;
	return $?
}

# Base
ins_glibc(){
	at gnu 2.42 &&\
	o &&\
	sed -e '/unistd.h/i #include <string.h>' \
		-e '/libc_rwlock_init/c\
  __libc_rwlock_define_initialized (, reset_lock);\
  memcpy (&lock, &reset_lock, sizeof (lock));' \
    -i stdlib/abort.c &&\
    wbd && bd && echo "rootsbindir=/usr/sbin" > configparms &&\
    cf  --prefix=/usr                   \
		 --disable-werror                \
		 --disable-nscd                  \
		 libc_cv_slibdir=/usr/lib        \
		 --enable-stack-protector=strong \
		 --enable-kernel=5.4 &&\
mo &&\
sed '/test-installation/s@$(PERL)@echo not running@' -i $sdir/$src/Makefile &&\

mi &&\	 
	sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd &&\
	localedef -i C -f UTF-8 C.UTF-8 &&\
	localedef -i en_US -f ISO-8859-1 en_US &&\
	localedef -i en_US -f UTF-8 en_US.UTF-8 &&\
	localedef -i es_ES -f ISO-8859-15 es_ES@euro &&\
	cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

say "Incorporando informacion timezone"
	wbd && bd &&\
	tar -xf $ldir/tzdata-2024b.tar.gz

	ZONEINFO=/usr/share/zoneinfo
	mkdir -pv $ZONEINFO/{posix,right}

	for tz in etcetera southamerica northamerica europe africa antarctica  \
			  asia australasia backward; do
		zic -L /dev/null   -d $ZONEINFO       ${tz}
		zic -L /dev/null   -d $ZONEINFO/posix ${tz}
		zic -L leapseconds -d $ZONEINFO/right ${tz}
	done

	cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
	zic -d $ZONEINFO -p Europe/Madrid
	unset ZONEINFO
	tzselect

	ln -sfv /usr/share/zoneinfo/Europe/Madrid /etc/localtime

	say "Configurando enlazador dinamico"
	cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF
		 
	return $?
}

ins_glibc32(){
	src="glibc"
	at gnu 2.42 &&\
	o && wbd && bd && cf32 --host=i686-club-linux-gnu --build=$($sdir/glibc/scripts/config.guess) \
      --enable-kernel=5.4                 \
      --disable-nscd                     \
      --libexecdir=/usr/lib32            \
      libc_cv_slibdir=/usr/lib32  &&\
    mo && mi32 &&\
  
	install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-32.h \
				   /usr/include/gnu/
	
	return $?
}


ins_libpipeline(){
	at https://download.savannah.nongnu.org/releases/libpipeline/libpipeline-1.5.8.tar.gz && $r
	return $?
}


ins_gmp(){
	at_gnu gmp 6.3.0 &&\
	sed -i '/long long t1;/,+1s/()/(...)/' configure &&\
	cf --prefix=/usr  --disable-static && mo && mi && make distclean &&\
	cp -v configfsf.guess config.guess &&\
	cp -v configfsf.sub   config.sub &&\
	ABI="32" \
	CFLAGS="-m32 -O2 -pedantic -fomit-frame-pointer -mtune=generic -march=i686" \
	CXXFLAGS="$CFLAGS" \
	PKG_CONFIG_PATH="/usr/lib32/pkgconfig" \
	./configure                      \
		--host=i686-pc-linux-gnu     \
		--prefix=/usr                \
		--disable-static             \
		--enable-cxx                 \
		--libdir=/usr/lib32          \
		--includedir=/usr/include/m32/gmp &&\
		sed -i 's/$(exec_prefix)\/include/$\(includedir\)/' Makefile && mo &&\
		make DESTDIR=$PWD/DESTDIR install &&\
		cp -Rv DESTDIR/usr/lib32/* /usr/lib32 &&\
		cp -Rv DESTDIR/usr/include/m32/* /usr/include/m32/ &&\
		rm -rf DESTDIR


	return $?
	
}
	
ins_mpfr(){
	at_gnu mpfr 4.2.0
	oa --disable-static --enable-thread-safe 
	return $?	
}

ins_mpc(){
	at_gnu mpc 1.3.1 
	oa --disable-static
	return $?
}

ins_libtirpc(){
	at https://downloads.sourceforge.net/libtirpc/libtirpc-1.3.7.tar.xz 
	oa --sysconfdir=/etc --disable-static --disable-gssapi
	return $?
}
	
ins_libnsl(){
	at https://github.com/thkukuk/libnsl/releases/download/v2.0.1/libnsl-2.0.1.tar.xz 
	CFLAGS="-I/usr/include/tirpc -ltirpc" oa
	return $?
}	
	
	
ins_zlib(){
	at https://www.zlib.net/zlib-1.3.1.tar.gz && $r && rm -fv /usr/lib/libz.a && make clean && r32
	return $?
}

ins_ncurses(){
	at https://invisible-island.net/archives/ncurses/ncurses-6.6.tar.gz &&\
	oc --prefix=/usr           \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig &&\
    mo &&\
	mkdir dest &&\
    make DESTDIR=dest install &&\
	sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h &&\
	cp --remove-destination -av dest/* / 
	for lib in ncurses form panel menu ; do
		ln -sfv /usr/lib/lib${lib}w.so /usr/lib/lib${lib}.so 
		ln -sfv /usr/lib/${lib}w.pc /usr/lib/pkgconfig/${lib}.pc     
	done 
    
	return $?
}

ins_pcre2(){
	at  https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.44/pcre2-10.44.tar.bz2 &&\
	 $r --enable-unicode                    \
            --enable-jit                        \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz             \
            --enable-pcre2grep-libbz2           \
            --enable-pcre2test-libreadline      \
            --disable-static  && make distclean && r32
}

ins_libelf(){
   # librería para manejar ficheros elf, parte de elfutils.
    # se compila multilib para herramientas de depuración y análisis.
    src="elfutils"
    at https://sourceware.org/ftp/elfutils/0.193/elfutils-0.193.tar.bz2 && o && bd

    # 1. compilación 64-bit
    say "compilando libelf para x86_64..." "⚙️"
    cf --prefix=/usr        \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy &&\

    mo && make -C libelf install &&\
    install -vm644 config/libelf.pc /usr/lib/pkgconfig &&\
	rm /usr/lib/libelf.a

    return $?
}

ins_libffi(){
    # Foreign Function Interface library, usada por intérpretes para llamar a librerías nativas.
    at https://github.com/libffi/libffi/releases/download/v3.5.2/libffi-3.5.2.tar.gz &&\
    $rud --with-gcc-arch=native && make distclean && r32 --disable-static --with-gcc-arch=i686 --host=i686-pc-linux-gnu
    return $?
}

ins_libxcrypt(){
	at https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz 
	
	CFLAGS="-Wno-error=unterminated-string-initialization"\
    cf  --enable-hashes=strong,glibc --enable-obsolete-api=no\
       --disable-static  --disable-failure-tokens &&\
    CFLAGS="-Wno-error=unterminated-string-initialization" mo && mi &&\
	make distclean && cf32  --host=i686-pc-linux-gnu &&\
	  CFLAGS="-Wno-error=unterminated-string-initialization"  mo && cp -av .libs/libcrypt.so* /usr/lib32/ &&
 CFLAGS="-Wno-error=unterminated-string-initialization"   make install-pkgconfigDATA &&
ln -svf libxcrypt.pc /usr/lib32/pkgconfig/libcrypt.pc
	return $?
}

ins_pam(){
	at https://github.com/linux-pam/linux-pam/releases/download/v1.7.1/Linux-PAM-1.7.1.tar.xz 
	return $?
}


ins_libpsl(){
	at https://github.com/rockdaboot/libpsl/releases/download/0.21.5/libpsl-0.21.5.tar.gz && $mu
	
	return $?
}

ins_libuv(){
	at https://dist.libuv.org/dist/v1.49.0/libuv-v1.49.0.tar.gz && o && ./autogen.sh && ca --prefix=/usr --disable-static && make distclean && r32
	return $?
}
ins_libarchive(){
	at https://github.com/libarchive/libarchive/releases/download/v3.8.1/libarchive-3.7.6.tar.xz && $r
	return $?
}

ins_libmnl(){
	at https://netfilter.org/projects/libmnl/files/libmnl-1.0.5.tar.bz2 && $r
	return $?
}
ins_libnftnl(){
	at https://netfilter.org/projects/libnftnl/files/libnftnl-1.3.1.tar.xz && $r
	return $?
}
ins_libedit(){
	at https://salsa.debian.org/debian/libedit/-/archive/3.1-20251016-1/libedit-3.1-20251016-1.tar.gz 3.1-20251016-1 tar.gz libedit-3.1-20251016-1 &&\
	at_name=libedit && $r
	return $?
}
ins_libcap(){
	 at https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.78.tar.xz &&\
	 o && bd && sed -i '/install -m.*STA/d' libcap/Makefile &&\
	 mia="prefix=/usr lib=lib" &&\
	 mo prefix=/usr lib=lib && mi 
	 return $?
}
ins_libusb(){
	 at https://github.com/libusb/libusb/releases/download/v1.0.29/libusb-1.0.29.tar.bz2 && $r
	 return $?
}
ins_popt(){
	at https://ftp.osuosl.org/pub/rpm/popt/releases/popt-1.x/popt-1.19.tar.gz &&\
	$r --disable-static 
	return $?
}

