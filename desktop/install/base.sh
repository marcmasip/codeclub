#!/usr/bin/env bash

. conf.sh

. $ldir/script/show.sh

. macro.sh



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
	
	
ins_zlib(){
	at https://www.zlib.net/zlib-1.3.1.tar.gz && $r && rm -fv /usr/lib/libz.a && make clean && r32
	return $?
}

ins_bzip2(){
	at https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz &&\
	o &&\
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile &&\
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile &&\
	make -f Makefile-libbz2_so &&\
	make clean &&\
	mia="PREFIX=/usr" &&\
	mo && mi && (
		cp -av libbz2.so.* /usr/lib 
		ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so 
		cp -v bzip2-shared /usr/bin/bzip2 
		for i in /usr/bin/{bzcat,bunzip2}; do 
		  ln -sfv bzip2 $i 
		done 
		rm -fv /usr/lib/libbz2.a
	)
	
	return $?
}

ins_bzip232(){
	src="bzip2"
	at https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz &&\
	
	o &&\
	sed -e "s/^CC=.*/CC=gcc -m32/" -i Makefile{,-libbz2_so} &&\
	make -f Makefile-libbz2_so &&\
	make libbz2.a &&\
	install -Dm755 libbz2.so.1.0.8 /usr/lib32/libbz2.so.1.0.8 &&\
	ln -sf libbz2.so.1.0.8 /usr/lib32/libbz2.so &&\
	ln -sf libbz2.so.1.0.8 /usr/lib32/libbz2.so.1 &&\
	ln -sf libbz2.so.1.0.8 /usr/lib32/libbz2.so.1.0 &&\
	install -Dm644 libbz2.a /usr/lib32/libbz2.a &&\
	di
	return $?
}

ins_xz(){
	at https://github.com/tukaani-project/xz/releases/download/v5.6.2/xz-5.6.2.tar.gz && $r && r32
	return $?
}

ins_lz4(){
	at https://github.com/lz4/lz4/releases/download/v1.10.0/lz4-1.10.0.tar.gz &&\
	fl="BUILD_STATIC=no PREFIX=/usr"
	o && mo $fl && mi $fl &&\ 
	make clean &&\
	mo32 $fl && mi32n $fl
	return $?
	
}
ins_zstd(){
	at https://github.com/facebook/zstd/releases/download/v1.5.6/zstd-1.5.6.tar.gz &&\
	o && mo prefix=/usr && mi prefix=/usr && rm -v /usr/lib/libzstd.a &&\
	make clean && mo32 prefix=usr && mi32n prefix=/usr &&
	
	sed -e "/^libdir/s/lib$/lib32/" -i /usr/lib32/pkgconfig/libzstd.pc
	return $?
}

ins_file(){
	at http://ftp.astron.com/pub/file/file-5.46.tar.gz && $r &&\
	make distclean && r32 --prefix=/usr         \
    --libdir=/usr/lib32   \
    --host=i686-pc-linux-gnu
	return $?
	
}


ins_readline(){
	at_gnu 8.2 &&\
	o && bd &&
	sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf &&\
	cf --prefix=/usr --disable-static --with-curses && LIBS="-lncursesw" mo SHLIB_LIBS="-lncursesw" && mi &&\
	make clean && cf32 --host=i686-pc-linux-gnu      \
    --disable-static              \
    --with-curses && mo32 && mi32
    
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

ins_m4(){
	ato gnu 1.4.20 &&\
	sed 's/\[\[__nodiscard__]]//' -i lib/config.hin &&\
	sed 's/test-stdalign\$(EXEEXT) //' -i tests/Makefile.in &&\
	cf --prefix=/usr && mo && mi && di
	return $?

}

ins_bc(){
	ato https://github.com/gavinhoward/bc/releases/download/7.0.3/bc-7.0.3.tar.xz && CC='gcc -std=c99' ./configure --prefix=/usr && mo && mi
	return $?
}

ins_flex(){
	 at https://github.com/westes/flex/files/981163/flex-2.6.4.tar.gz &&\|
	 $r --with-gnu-ld --enable-shared 
	 return $?
}
ins_pkgconf(){
	at https://distfiles.ariadne.space/pkgconf/pkgconf-2.5.1.tar.xz && $r &&\
	ln -sv pkgconf   /usr/bin/pkg-config &&\
	ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1
	return $?
}

ins_binutils(){
	at gnu 2.44 &&\
	wbd &&\
	oc --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --enable-multilib \
             --enable-default-hash-style=gnu &&\
    make tooldir=/usr -j$JOBS &&\
    make tooldir=/usr install &&\
    rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a
    
    return $?
	
}

ins_gmp(){
	ato gnu gmp 6.3.0 &&\
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
	at gnu mpfr 4.2.0 && $r --disable-static --enable-thread-safe 


	return $?
	
}

ins_mpc(){
	at gnu mpc 1.3.1 && $r --disable-static


	return $?
	
}

ins_libtirpc(){
	at https://downloads.sourceforge.net/libtirpc/libtirpc-1.3.7.tar.xz && $r --sysconfdir=/etc --disable-static --disable-gssapi
	return $?
}
	
ins_libnsl(){
	at https://github.com/thkukuk/libnsl/releases/download/v2.0.1/libnsl-2.0.1.tar.xz && CFLAGS="-I/usr/include/tirpc -ltirpc" $r
	return $?
}	


ins_attr(){
	at https://download-mirror.savannah.gnu.org/releases/attr/attr-2.5.2.tar.xz && $r --disable-static --sysconfdir=/etc && make distclean && r32
	return $?
}

ins_acl(){
	at https://download-mirror.savannah.gnu.org/releases/acl/acl-2.3.2.tar.xz && $r --disable-static && make distclean && r32 --prefix=/usr         \
    --disable-static  --libdir=/usr/lib32  --libexecdir=/usr/lib32   --host=i686-pc-linux-gnu
    return $?
}

ins_libxcrypt(){
	 at https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz && o && bd && CFLAGS="-Wno-error=unterminated-string-initialization" cf  --enable-hashes=strong,glibc --enable-obsolete-api=no   --disable-static  --disable-failure-tokens && CFLAGS="-Wno-error=unterminated-string-initialization" make && mi &&\
	make distclean && cf32  --host=i686-pc-linux-gnu &&\
	
	
	  CFLAGS="-Wno-error=unterminated-string-initialization"  mo && cp -av .libs/libcrypt.so* /usr/lib32/ &&
 CFLAGS="-Wno-error=unterminated-string-initialization"   make install-pkgconfigDATA &&
ln -svf libxcrypt.pc /usr/lib32/pkgconfig/libcrypt.pc
	return $?
}

ins_shadow(){
		at  https://github.com/shadow-maint/shadow/releases/download/4.16.0/shadow-4.16.0.tar.xz && 	$r --sysconfdir=/etc   \
            --disable-static    \
            --without-libbsd    \
            --without-libpam \
            --with-{b,yes}crypt
}

ins_gcc(){
	
	ato https://ftp.rediris.es/mirror/GNU/gcc/gcc-15.2.0/gcc-15.2.0.tar.xz &&\
	
	sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64 &&\
    sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h &&\
      
    mlist=m64,m32  &&\
    
	ca --prefix=/usr               \
             LD=ld                       \
             --build=$otar \
             --host=$otar \
             --target=$otar \
             --enable-languages=c,c++    \
             --enable-default-pie        \
             --enable-default-ssp        \
             --enable-host-pie           \
             --enable-multilib           \
             --with-multilib-list=$mlist \
             --disable-bootstrap         \
             --disable-fixincludes       \
             --with-system-zlib
     
}

ins_pam(){
	at https://github.com/linux-pam/linux-pam/releases/download/v1.7.1/Linux-PAM-1.7.1.tar.xz 
	
}

ins_ncurses(){
	at_gnu 6.5
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
	install -vm755 dest/usr/lib/libncursesw.so.6.5 /usr/lib
	rm -v  dest/usr/lib/libncursesw.so.6.5
	sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h
	cp -av dest/* /
    for lib in ncurses form panel menu ; do
		ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
		ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
	done
	ln -sfv libncursesw.so /usr/lib/libcurses.so
	cp -v -r doc -T /usr/share/doc/ncurses-6.5
	
	make distclean &&
	cf32  --prefix=/usr           \
            --host=i686-pc-linux-gnu \
            --libdir=/usr/lib32     \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib32/pkgconfig && mo &&\
            make DESTDIR=$PWD/DESTDIR install
mkdir -p DESTDIR/usr/lib32/pkgconfig
for lib in ncurses form panel menu ; do
    rm -vf                    DESTDIR/usr/lib32/lib${lib}.so
    echo "INPUT(-l${lib}w)" > DESTDIR/usr/lib32/lib${lib}.so
    ln -svf ${lib}w.pc        DESTDIR/usr/lib32/pkgconfig/$lib.pc
done
rm -vf                     DESTDIR/usr/lib32/libcursesw.so
echo "INPUT(-lncursesw)" > DESTDIR/usr/lib32/libcursesw.so
ln -sfv libncurses.so      DESTDIR/usr/lib32/libcurses.so
cp -Rv DESTDIR/usr/lib32/* /usr/lib32
rm -rf DESTDIR

	return $?
}

ins_sed(){
	at_gnu 4.9 && $r
	return $?	
}
ins_autoconf(){
	at_gnu 2.72 && $r 
	return $?
}
ins_psmisc(){
	at https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-23.7.tar.xz && $r --prefix=/usr
	return $?
}
ins_gettext(){
	at_gnu 0.26 && $r 
	return $?
}
ins_bison(){
	at_gnu 3.8.2 && $r
}
ins_grep(){
    at_gnu 3.12 && $r
    return $?
}

ins_bash(){
    at_gnu 5.3 &&\
    oa --prefix=/usr --without-bash-malloc --with-installed-readline
    return $?
}
ins_libtool(){
    # Herramienta para gestionar la creación de librerías compartidas.
    at_gnu 2.5.4 && $r
    return $?
}

ins_gdbm(){
    # Una librería de base de datos clave-valor.
    # --enable-libgdbm-compat para compatibilidad con aplicaciones antiguas.
    at_gnu 1.26 &&\
    $ru --disable-static --enable-libgdbm-compat && make distclean && r32 --disable-static --enable-libgdbm-compat
    return $?
}

ins_gperf(){
    # Generador de funciones hash perfectas, usado por muchos paquetes.
    at_gnu 3.3 && $r
    return $?
}

ins_expat(){
    # Un parser de XML rápido y ligero.
    at https://github.com/libexpat/libexpat/releases/download/R_2_7_3/expat-2.7.3.tar.xz &&\
    $ru && make distclean && r32 --disable-static
    return $?
}
ins_inetutils(){
    # Utilidades de red como telnet, ftp, etc.
    # Deshabilitamos los servidores y herramientas obsoletas o inseguras.
    at_gnu 2.6 &&\
    LIBS="-lncursesw" oa --prefix=/usr --disable-logger --disable-whois --disable-rcp \
       --disable-rexec --disable-rlogin --disable-rsh --disable-servers
    return $?
}
ins_dhcpcd(){
	at "https://github.com/NetworkConfiguration/dhcpcd/releases/download/v10.0.8/dhcpcd-10.0.8.tar.xz" && \
	$r      --sysconfdir=/etc            \
            --libexecdir=/usr/lib/dhcpcd \
            --dbdir=/var/lib/dhcpcd      \
            --runstatedir=/run           \
            --disable-privsep
	return $?
}
ins_ntp(){
	at "https://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p18.tar.gz" && \
	o && sed -e "s;pthread_detach(NULL);pthread_detach(0);" \
    -i configure \
       sntp/configure && ca --prefix=/usr --bindir=/usr/sbin \
            --sysconfdir=/etc  \
            --enable-linuxcaps \
            --with-lineeditlibs=readline 
	return $?
}
ins_chrony(){
	at "https://chrony-project.org/releases/chrony-4.8.tar.gz" && $r
	return $?
}
ins_less(){
    # Un paginador de texto avanzado, superior a `more`.
    at http://www.greenwoodsoftware.com/less/less-679.tar.gz &&\
    oa --prefix=/usr --sysconfdir=/etc
    return $?
}
ins_perl(){
	  at https://www.cpan.org/src/5.0/perl-5.42.0.tar.gz && o && bd &&\
	export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des                                          \
             -D prefix=/usr                                \
             -D vendorprefix=/usr                          \
             -D privlib=/usr/lib/perl5/5.42/core_perl      \
             -D archlib=/usr/lib/perl5/5.42/core_perl      \
             -D sitelib=/usr/lib/perl5/5.42/site_perl      \
             -D sitearch=/usr/lib/perl5/5.42/site_perl     \
             -D vendorlib=/usr/lib/perl5/5.42/vendor_perl  \
             -D vendorarch=/usr/lib/perl5/5.42/vendor_perl \
             -D pager="/usr/bin/less -isR"                 \
             -D useshrplib                                 \
             -D usethreads
   return $?
}

ins_xml_parser(){
    # Módulo de Perl para parsear XML. Dependencia de intltool.
    src="XML-Parser"
    at https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.47.tar.gz &&\
    o && bd && perl Makefile.PL && mo && mi
    src="xml_parser"
    return $?
}

ins_intltool(){
    # Herramienta para extraer cadenas traducibles de ficheros fuente.
    at https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz && $r
    return $?
}

ins_diffutils(){
    # Utilidades para comparar ficheros, esencial para parches y desarrollo.
    at_gnu 3.12 && $r
    return $?
}

ins_coreutils(){
    # El paquete con las herramientas básicas (ls, cat, rm, etc.).
    # 'NON_ROOT_USERNAME=nobody' es una medida de seguridad durante las pruebas de 'make check'.
    at_gnu 9.5 &&\
    oa --prefix=/usr --enable-install-program=hostname &&\
    mo NON_ROOT_USERNAME=nobody -k check &&\
    mi
    return $?
}

ins_automake(){
    # Crea 'Makefile.in' para ser usados por Autoconf.
    at_gnu 1.18.1 && $r --docdir=/usr/share/doc/automake-1.18.1
    return $?
}

ins_openssl(){
    # La librería criptográfica por excelencia. Su compilación no es estándar.
    # Se configura para 64 bits y luego para 32 bits (linux-x86).
    at https://www.openssl.org/source/openssl-3.5.2.tar.gz && o && bd &&\
    ./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic &&\
    mo && mi &&\
    make clean &&\
    ./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib32 shared zlib-dynamic linux-x86 &&\
    mo && make DESTDIR=$PWD/DESTDIR install &&\
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32 && rm -rf DESTDIR
    return $?
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

ins_sqlite(){
    # Motor de base de datos SQL embebido.
    src="sqlite-autoconf"
    # Activamos FTS5, una extensión muy útil para búsqueda de texto completo.
    at https://www.sqlite.org/2025/sqlite-autoconf-3500400.tar.gz &&\
    CFLAGS="-DSQLITE_ENABLE_FTS5" $rud && make distclean &&\
    CFLAGS="-m32 -DSQLITE_ENABLE_FTS5" r32 --disable-static --host=i686-pc-linux-gnu
    return $?
}
ins_wget(){
	at gnu 1.24.5 &&\
	$r --with-gnu-ld --sysconfdir=/etc --with-ssl=openssl
	return $?
}
ins_xml_parser(){
    # Módulo de Perl para parsear XML. Dependencia de intltool.
    src="XML-Parser"
    at https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.47.tar.gz &&\
    o && bd && perl Makefile.PL && mo && mi
    src="xml_parser"
    return $?
}
ins_kmod(){
    # Librería y utilidades para gestionar módulos del kernel.
    at https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-32.tar.xz &&\
    oa --prefix=/usr --sysconfdir=/etc --with-zlib --with-xz --with-rootlibdir=/usr/lib &&\
    make distclean &&\
    cf32 --prefix=/usr --sysconfdir=/etc --with-zlib --with-xz --with-rootlibdir=/usr/lib32 --host=i686-pc-linux-gnu &&\
    mo && mi32
    return $?
}
ins_python(){
    # El intérprete de Python 3. Esencial para Meson y mucho software moderno.
    src="Python"
    at https://www.python.org/ftp/python/3.13.7/Python-3.13.7.tgz &&\
    oa --prefix=/usr --enable-shared --with-system-expat  --enable-optimizations  --without-static-libpython --with-system-ffi --with-openssl=/usr --enable-optimizations
    return $?
}

ins_ninja(){
	export NINJAJOBS=4
	at https://github.com/ninja-build/ninja/archive/refs/tags/v1.12.1.tar.gz 1.12.1 &&\
	o && python3 configure.py --bootstrap &&\
	install -vm755 ninja /usr/bin/ &&\
	install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja &&\
	install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja 
	 return $?
}
ins_meson(){
	pip3 install meson 
	return $?
}
ins_coreutils(){
	at_gnu 9.8 &&\
	oa --prefix=/usr FORCE_UNSAFE_CONFIGURE=1 --enable-install-program=hostname --enable-no-install-program=kill,uptime
	return $?
}
ins_coreutils(){
	at_gnu 3.12 && $r
	return $?
}
ins_gawk(){
	at_gnu 5.3.2 && $r
	return $?
}
ins_findutils(){
	at_gnu findutils 4.10.0 tar.xz && $r --localstatedir=/var/lib/locate
	return $?
}
ins_groff(){
	at_gnu 1.23.0 && PAGE=A4 $r
	return $?
}
ins_grub(){
	at_gnu 2.12 && o && bd &&\
	echo depends bli part_gpt > grub-core/extra_deps.lst &&\
	ca --prefix=/usr --sysconfdir=/etc    \
            --disable-efiemu     \
            --with-platform=efi  \
            --target=x86_64      \
            --disable-werror
	return $?
}
ins_popt(){
	at https://ftp.osuosl.org/pub/rpm/popt/releases/popt-1.x/popt-1.19.tar.gz &&\
	$r --disable-static 
	return $?
}
ins_efivar(){
	at https://github.com/rhboot/efivar/archive/39/efivar-39.tar.gz &&\
	o && bd && mo ENABLE_DOCS=0 && mi ENABLE_DOCS=0 LIBDIR=/usr/lib 
	return $?
}
ins_efibootmgr(){
	at  https://github.com/rhboot/efibootmgr/archive/18/efibootmgr-18.tar.gz &&\
	o && bd && mo  EFIDIR=LFS EFI_LOADER=grubx64.efi && mi EFIDIR=LFS
	return $?
}

ins_gzip(){
	at_gnu  1.13 && $r
	return $?
}
ins_iproute2(){
	at https://git.kernel.org/pub/scm/network/iproute2/iproute2.git/snapshot/iproute2-6.11.0.tar.gz &&\
	o &&
	sed -i /ARPD/d Makefile &&\
	rm -fv man/man8/arpd.8 &&\
	make NETNS_RUN_DIR=/run/netns &&\
	make SBINDIR=/usr/sbin install
	return $?
}
ins_kbd(){
	at https://mirrors.edge.kernel.org/pub/linux/utils/kbd/kbd-2.8.0.tar.gz  &&\
	o &&\
	sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure &&\
	sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in &&\
	$r --disable-vlock
	return $?
}
ins_libpipeline(){
	at https://download.savannah.nongnu.org/releases/libpipeline/libpipeline-1.5.8.tar.gz && $r
	return $?
}
ins_make(){
	at_gnu 4.4.1 && $r
	return $?
}
ins_patch(){
	at_gnu 2.8 && $r
	return $?
}
ins_tar(){
	at_gnu 1.35 && FORCE_UNSAFE_CONFIGURE=1 $r
	return $?
}
ins_texinfo(){
	at_gnu 7.2 && o && sed 's/! $output_file eq/$output_file ne/' -i tp/Texinfo/Convert/*.pm && $r
	return $?
}
ins_vim(){
	at https://github.com/vim/vim/archive/refs/tags/v9.1.1831.tar.gz 9.1.1831 tar.gz && $r
	
}
ins_libpsl(){
	at https://github.com/rockdaboot/libpsl/releases/download/0.21.5/libpsl-0.21.5.tar.gz && $mu
	
	return $?
}
	
ins_curl(){
	at https://curl.se/download/curl-8.16.0.tar.xz &&\
	$r --disable-static --with-openssl  --with-ca-path=/etc/ssl/certs --with-ca=/etc/ssl/certs
	
	return $?	
}
ins_openssl(){
	at https://github.com/openssl/openssl/releases/download/openssl-3.3.2/openssl-3.3.2.tar.gz &&\
	o && ./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic && mo && \
         sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile &&\
		make MANSUFFIX=ssl install_sw
		
	return $?
}
ins_git(){
	at https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.51.0.tar.gz &&\
	$r --with-openssl --without-tcltk
	return $?
}
ins_markupsafe(){
	pip3 install Markupsafe
	return $?
}
ins_jninja(){
	pip3 install Jninja2
	return $?
}
ins_eudev(){
	at https://github.com/eudev-project/eudev/releases/download/v3.2.14/eudev-3.2.14.tar.gz && $r
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
ins_cmake(){
	at https://github.com/Kitware/CMake/releases/download/v4.3.0-rc1/cmake-4.3.0-rc1.tar.gz 4.3.0-rc1 && o && bd &&\
	sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake &&\
./bootstrap --prefix=/usr        \
            --system-libs        \
            --mandir=/share/man  \
            --no-system-jsoncpp  \
            --no-system-cppdap   \
            --no-system-librhash && mo && mi && di 
   return $?
}
ins_llvm(){


    src="cmake" 
    at https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.2/cmake-21.1.2.src.tar.xz && o &&\
    src="llvm-third-party" 
    at https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.2/third-party-21.1.2.src.tar.xz && o &&\
    src="llvm" 
    at https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.2/llvm-21.1.2.src.tar.xz && o &&\
    

	#mv $sdir/cmake/Modules/* $sdir/$src/cmake/modules &&\
	#mv $sdir/third-party $sdir/$src &&\
	sed '/LLVM_COMMON_CMAKE_UTILS/s@../cmake@llvm-cmake@'          \
    -i CMakeLists.txt                                                 &&\
	sed '/LLVM_THIRD_PARTY_DIR/s@../third-party@llvm-third-party@' \
    -i cmake/modules/HandleLLVMOptions.cmake &&\
    wbd && bd &&\
       cmn -D CMAKE_INSTALL_PREFIX=/usr           \
      -D CMAKE_SKIP_INSTALL_RPATH=ON         \
      -D LLVM_ENABLE_FFI=ON                  \
      -D CMAKE_BUILD_TYPE=release            \
      -D LLVM_BUILD_LLVM_DYLIB=ON            \
      -D LLVM_LINK_LLVM_DYLIB=ON             \
      -D LLVM_ENABLE_RTTI=ON                 \
      -D LLVM_TARGETS_TO_BUILD="host;AMDGPU" \
      -D LLVM_BINUTILS_INCDIR=/usr/include   \
      -D LLVM_INCLUDE_BENCHMARKS=OFF         \
      -D CLANG_DEFAULT_PIE_ON_LINUX=ON       \
      -D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang
      
		return $?
}
ins_procps_ng(){
	src="procps"
	at https://gitlab.com/procps-ng/procps/-/archive/v4.0.5/procps-v4.0.5.tar.gz v4.0.5 && o && ./autogen.sh --prefix=/usr &&  CFLAGS="-lncursesw" ca --help
}

ins_zfs(){
	at https://github.com/openzfs/zfs/releases/download/zfs-2.4.1/zfs-2.4.1.tar.gz &&\
	o && bd && cf --prefix=/usr --with-gnu-ld --disable-pyzfs  \
	--enable-linux-builtin \
	--with-linux=$ldir/develop/linux-6.19.6 \
	--with-linux-obj=$bdir/linux-club-server-6.19.6 \
	--disable-linux-config-check --disable-systemd --disable-code-coverage --disable-sysvinit --disable-pam  &&\
	mo && exit
	return $?
}



ins_libmnl(){
	at https://netfilter.org/projects/libmnl/files/libmnl-1.0.5.tar.bz2 && $r
	return $?
}
ins_libnftnl(){
	at https://www.netfilter.org/projects/libnftnl/files/libnftnl-1.3.1.tar.xz && $r
	return $?
}
ins_libedit(){
	at https://salsa.debian.org/debian/libedit/-/archive/3.1-20251016-1/libedit-3.1-20251016-1.tar.gz 3.1-20251016-1 &&\
	at_name=libedit && $r
	return $?
}
ins_nftables(){
	at https://www.netfilter.org/projects/nftables/files/nftables-1.1.6.tar.xz && $r
	return $?
}
ins_iptables(){
	at https://www.netfilter.org/projects/iptables/files/iptables-1.8.10.tar.xz &&\
	$r --enable-libipq
	return $?
}	
	
ins_bridge_utils(){
	at "https://www.kernel.org/pub/linux/utils/net/bridge-utils/bridge-utils-1.7.1.tar.xz" &&\
		o && bd && autoconf && ca --prefix=/usr
	return $?
}

run_item
