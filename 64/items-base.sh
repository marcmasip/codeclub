# Base components setup

# Shortcuts

pfu="--prefix=/usr"
r="OA $pfu"
rds="OA $pfu --disable-static"
rc="CF $pfu"
rns="OC $pfu"
mu="MES $pfu"
mur="$mu $pfu"



CF32(){
	CC="gcc -m32" CXX="g++ -m32" &&\
	echo --prefix=/usr --host=i686-pc-linux-gnu --libdir=/usr/lib32 $@  
	exit
}

R32(){
	CF32 $@ && MO && MI32
	
	
}

RO32(){
	 CF32 && MO 
}

MI32(){
	MIA="$@ DESTDIR=$PWD/DESTDIR" MI &&\
	cp -Rv DESTDIR/usr/lib32/* /usr/lib32
}



# Item plans



case "$ITEM" in

"glibc")
	O &&\
	WBD &&\
	echo "rootsbindir=/usr/sbin" > configparms &&\
	$rc --disable-werror \
		--enable-stack-protector=strong \
		--disable-nscd  \
		--enable-static-nss \
		libc_cv_slibdir=/usr/lib &&\
	MO &&\
	sed 's/.*test-installation.*/ #/g' -i $SDIR/$SRC/Makefile &&\
	make install
;;

"glibc-setup")
	localedef -i es_ES -f UTF-8 es_ES.UTF-8 && \
	
	FDEF /etc/hosts
	FDEF /etc/passwd
	FDEF /etc/group
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

	SAY "Incorporando informacion timezone"
	WBD && BD &&\
	tar -xf $LDIR/tzdata-2024b.tar.gz

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

	SAY "Configurando enlazador dinamico"
	cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

	
;;


"glibc-32")
	O && WBD && BD && CF32 --build=$($SDIR/glibc/scripts/config.guess) \
      --enable-kernel=5.4                 \
      --disable-nscd                     \
      --libexecdir=/usr/lib32            \
      libc_cv_slibdir=/usr/lib32  &&\
    MO && MI32 &&\
  
	install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-32.h \
				   /usr/include/gnu/
;;



"zlib-32") CFLAGS+=" -m32" CXXFLAGS+=" -m32" $r --libdir=/usr/lib32  ;;


"bzip2")
	O
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
	
	make -f Makefile-libbz2_so &&\
	make clean &&\
	MO &&\
	make PREFIX=/usr install 
	cp -av libbz2.so.* /usr/lib 
	ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so 
	cp -v bzip2-shared /usr/bin/bzip2 
	for i in /usr/bin/{bzcat,bunzip2}; do 
	  ln -sfv bzip2 $i 
	done 
	rm -fv /usr/lib/libbz2.a
;;

"bzip2-32") SRC="bzip2"
	O &&\
	sed -e "s/^CC=.*/CC=gcc -m32/" -i Makefile{,-libbz2_so} &&\
	make -f Makefile-libbz2_so &&\
	make libbz2.a &&\
	install -Dm755 libbz2.so.1.0.8 /usr/lib32/libbz2.so.1.0.8 &&\
	ln -sf libbz2.so.1.0.8 /usr/lib32/libbz2.so &&\
	ln -sf libbz2.so.1.0.8 /usr/lib32/libbz2.so.1 &&\
	ln -sf libbz2.so.1.0.8 /usr/lib32/libbz2.so.1.0 &&\
	install -Dm644 libbz2.a /usr/lib32/libbz2.a &&\
	DI
;;


"xz")  $r --disable-static ;;
"xz-32") R32 --disable-static ;;

"lz4")
	O && BD &&
	make BUILD_STATIC=no PREFIX=/usr &&\
	make BUILD_STATIC=no PREFIX=/usr install 
;;
"lz4-32")
	O && BD &&
	CC="gcc -m32" make BUILD_STATIC=no &&\
	make BUILD_STATIC=no PREFIX=/usr LIBDIR=/usr/lib32 DESTDIR=$(pwd)/m32 install &&
	cp -a m32/usr/lib32/* /usr/lib32/

;;



"zstd")
	O && BD &&
	make prefix=/usr &&\
	make prefix=/usr install &&\
	rm -v /usr/lib/libzstd.a
;;
"zstd-32")
	O && BD &&
	CC="gcc -m32" make prefix=/usr && RI32 &&\
	sed -e "/^libdir/s/lib$/lib32/" -i /usr/lib32/pkgconfig/libzstd.pc \
	&& RID32
;;


"readline")
	
	O && BD &&
	sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf
	$r --disable-static --with-curses
;;

"readline-32")
	O && BD &&\	
	sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf &&\
	CF32	--disable-static --with-curses &&\
	MO 		SHIB_LIBS="-lncursesw"  &&\
	MI32	SHIB_LIBS="-lncursesw"
;;

"openssl") 
	O 
	./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic && MO && \
         sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile &&\
		make MANSUFFIX=ssl install


;;

"certs")
	cp $CDIR/util/info/ca-bundle.crt.1 /etc/ssl/certs/bundle.crt
	
;;

"test")

;;

"inetutils") 
	O
	sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c
	CA --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers &&
   echo "nameserver 8.8.8.8" > /etc/resolv.conf
;;

"pkgconf") 
	$r --disable-static &&\
       ln -sfv /usr/bin/pkgconf /usr/bin/pkg-config
            
;;
"binutils")
	WBD &&\
	OC --prefix=/usr       \
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
         
;;

"wget") $r --with-gnu-ld --sysconfdir=/etc --with-ssl=openssl ;;
"git") $r --with-openssl --without-tcltk ;;
"gmp") $r --enable-cxx     --disable-static ;;
"mpfr") $r --disable-static --enable-thread-safe ;;
"mpc") $r --disable-static ;;

"libxcrypt")
	$r --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens
;;



"gcc")  
	WBD && O && BD &&\
	sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64 &&\
    
    sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h &&\
      
    mlist=m64,m32  &&\
    
	CA --prefix=/usr               \
             LD=ld                       \
             --enable-languages=c,c++    \
             --enable-default-pie        \
             --enable-default-ssp        \
             --enable-host-pie           \
             --enable-multilib           \
             --with-multilib-list=$mlist \
             --disable-bootstrap         \
             --disable-fixincludes       \
             --with-system-zlib
          
;;

"ncurses")
	OC --prefix=/usr           \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig &&\
    MO &&\
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
	cp -v -R doc -T /usr/share/doc/ncurses-6.5
      
;;


"psmisc") O && ./autogen.sh && CF --prefix=/usr && MO && MI ;;
"gettext") $r --disable-static ;;
"bison") $r --disable-static ;;

"bash") $r --without-bash-malloc     \
        --with-installed-readline \
        bash_cv_strtold_broken=no
;;

"certs")
	cp $CDIR/util/info/ca-bundle.crt /etc/ssl/certs/bundle.crt
	
;;

"perl") 
	O
	export BUILD_ZLIB=False
	export BUILD_BZIP2=0
	pp=/usr/lib/perl5/5.38/
	./Configure -des                                          \
             -D prefix=/usr                                \
             -D vendorprefix=/usr                          \
             -D privlib=$pp/core_perl      \
             -D archlib=$pp/core_perl      \
             -D sitelib=$pp/site_perl      \
             -D sitearch=$pp/site_perl     \
             -D vendorlib=$pp/vendor_perl  \
             -D vendorarch=$pp/vendor_perl \
             -D man1dir=/usr/share/man/man1                \
             -D man3dir=/usr/share/man/man3                \
             -D pager="/usr/bin/less -isR"                 \
             -D useshrplib                                 \
             -D usethreads &&\
    cd $SDIR/$SRC &&\
    sed -i -e "s/d_perl_lc_all_category_positions_init=.*/d_perl_lc_all_category_positions_init='define'/g" \
	-e "s/d_perl_lc_all_separator=.*/d_perl_lc_all_separator='define'/g" \
	-e "s/d_perl_lc_all_uses_name_value_pairs=.*/d_perl_lc_all_uses_name_value_pairs='define'/g" config.sh &&\
	MO && MI &&\
	unset BUILD_ZLIB BUILD_BZIP2 
;;


"eudev")
	O &&\
	sed -i -e 's/GROUP="sgx", //' rules/50-udev-default.rules &&\
	CA  --bindir=/sbin          \
            --sbindir=/sbin         \
            --libdir=/usr/lib       \
            --sysconfdir=/etc       \
            --libexecdir=/usr/lib       \
            --with-rootprefix=      \
            --with-rootlibdir=/usr/lib \
            --disable-static
     #mkdir -pv /usr/lib/udev/rules.d
	 #mkdir -pv /etc/udev/rules.d
;;
"libtirpc")
	$r\
		--sysconfdir=/etc                               \
		--disable-static                                \
		--disable-gssapi 
;;

"libtool") $r ;; 
"less") $r ;; 

"perl") 
	O
	export BUILD_ZLIB=False
	export BUILD_BZIP2=0
	pp=/usr/lib/perl5/5.38/
	./Configure -des                                          \
             -D prefix=/usr                                \
             -D vendorprefix=/usr                          \
             -D privlib=$pp/core_perl      \
             -D archlib=$pp/core_perl      \
             -D sitelib=$pp/site_perl      \
             -D sitearch=$pp/site_perl     \
             -D vendorlib=$pp/vendor_perl  \
             -D vendorarch=$pp/vendor_perl \
             -D man1dir=/usr/share/man/man1                \
             -D man3dir=/usr/share/man/man3                \
             -D pager="/usr/bin/less -isR"                 \
             -D useshrplib                                 \
             -D usethreads &&\
    cd $SDIR/$SRC &&\
    sed -i -e "s/d_perl_lc_all_category_positions_init=.*/d_perl_lc_all_category_positions_init='define'/g" \
	-e "s/d_perl_lc_all_separator=.*/d_perl_lc_all_separator='define'/g" \
	-e "s/d_perl_lc_all_uses_name_value_pairs=.*/d_perl_lc_all_uses_name_value_pairs='define'/g" config.sh &&\
	MO && MI &&\
	unset BUILD_ZLIB BUILD_BZIP2 
;;

"kmod")
	$r --sysconfdir=/etc \
            --with-openssl    \
            --with-xz         \
            --with-zstd       \
            --with-zlib       \
            --disable-manpages
;;


"flex") $r --host=$TARGET --build=$TARGET --with-gnu-ld --enable-shared ;;


"libelf") SRC="elfutils"
	O
	$r                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy &&\
    MO && make -C libelf install &&\
    install -vm644 config/libelf.pc /usr/lib/pkgconfig &&\
rm /usr/lib/libelf.a 
;;

"libffi")
	$r 	--libdir=/usr/lib	 \
            --disable-static       \
            --with-gcc-arch=native
;;

"libexpat")
	$r  --disable-static 
;;
"Python")
	$r --enable-shared      \
            --with-system-expat  \
            --with-openssl=/usr \
            --enable-optimizations &&\
    cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF
	
	python3 -m ensurepip --default-pip

;;


"flit-core")
	O &&\
	pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps  . && \
pip3 install --no-index --no-user --find-links dist flit_core

;;
"wheel")
	O
	pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps  . && \
pip3 install --no-index --find-links=dist wheel

;;
"setuptools")
	 pip3 install --upgrade setuptools

;;
"ninja")
	O
	export NINJAJOBS=4
	python3 configure.py --bootstrap &&\
	install -vm755 ninja /usr/bin/ &&\
	install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja &&\
	install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja 
;;

"meson")
	O
	pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps . &&\
pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson
;;

"coreutils")
	O  && CA --prefix=/usr \
	FORCE_UNSAFE_CONFIGURE=1 --enable-no-install-program=kill,uptime  ;;


"diffutils") $r ;;


"gawk")
	O
	sed -i 's/extras//' Makefile.in &&\
	CF --prefix=/usr &&\
	MO && rm -f /usr/bin/gawk-5.3.0 && MI
		
;;
"findutils") $r ;;

"iproute2") 
	O &&
	sed -i /ARPD/d Makefile &&\
	rm -fv man/man8/arpd.8 &&\
	make NETNS_RUN_DIR=/run/netns &&\
	make SBINDIR=/usr/sbin install
 ;;
 
 "kbd")
 O &&\
 sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure &&\
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in &&\
 $r --disable-vlock;
 ;;
 
 "make") $r ;;
 "patch") $r ;;
 "tar") $r  FORCE_UNSAFE_CONFIGURE=1  ;;
 "texinfo") $r ;;
 
 "libpipeline") $r ;;
 
 "util-linux")
 
	OA --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            --without-systemd     \
            --without-systemdsystemunitdir        \
            ADJTIME_PATH=/var/lib/hwclock/adjtime 
;;

"libpsl") $r ;;
  
"curl") $r --with-openssl --with-ca-bundle=/etc/ssl/certs/bundle.crt --with-ca-path=/etc/ssl/certs ;;

"e2fsprogs")
WBD && $r  --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
;;
"check") $r ;;

"asciidoc")
	$r --sysconfdir=/etc
;;

"syslinux") 

	O && BD && make bios install
;;


"dhcpcd")
	$r --sysconfdir=/etc            \
            --libexecdir=/usr/lib/dhcpcd \
            --dbdir=/var/lib/dhcpcd      \
            --runstatedir=/run           \
            --disable-privsep
;;
"XML-Parser")
	O && BD && perl Makefile.PL && make && make install
;;

"vim")
	$r --with-features=small \
	--with-timer-create \
            --with--enable-timer-create \
            --with-tlib=ncurses
;;


"cmake") O &&\
sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake &&\
./bootstrap --prefix=/usr        \
            --system-libs        \
            --mandir=/share/man  \
            --no-system-jsoncpp  \
            --no-system-cppdap   \
            --no-system-librhash && MO && MI && DI 
;;

"llvm")
	O llvm-cmake &&\
	O llvm-third-party &&\
	O &&\
	mv $SDIR/llvm-cmake $SDIR/$SRC &&\
	mv $SDIR/llvm-third-party $SDIR/$SRC &&\
	sed '/LLVM_COMMON_CMAKE_UTILS/s@../cmake@llvm-cmake@'          \
    -i CMakeLists.txt                                                 &&\
	sed '/LLVM_THIRD_PARTY_DIR/s@../third-party@llvm-third-party@' \
    -i cmake/modules/HandleLLVMOptions.cmake &&\
    WBD && BD &&\
    CC=gcc CXX=g++ &&\
    cmake -D CMAKE_INSTALL_PREFIX=/usr           \
      -D CMAKE_SKIP_INSTALL_RPATH=ON         \
      -D LLVM_ENABLE_FFI=ON                  \
      -D CMAKE_BUILD_TYPE=Release            \
      -D LLVM_BUILD_LLVM_DYLIB=ON            \
      -D LLVM_LINK_LLVM_DYLIB=ON             \
      -D LLVM_ENABLE_RTTI=ON                 \
      -D LLVM_TARGETS_TO_BUILD="host;AMDGPU" \
      -D LLVM_BINUTILS_INCDIR=/usr/include   \
      -D LLVM_INCLUDE_BENCHMARKS=OFF         \
      -D CLANG_DEFAULT_PIE_ON_LINUX=ON       \
      -D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang \
      -W no-dev -G Ninja $SDIR/$SRC                  &&
ninja && ninja install
	
	
	
;;

"shadow")
	$r --sysconfdir=/etc   \
            --disable-static    \
            --without-libbsd    \
            --with-{b,yes}crypt
;;

"nss")
O && cd nss &&\
make BUILD_OPT=1                      \
  NSPR_INCLUDE_DIR=/usr/include/nspr  \
  USE_SYSTEM_ZLIB=1                   \
  ZLIB_LIBS=-lz                       \
  NSS_ENABLE_WERROR=0                 \
  $([ $(uname -m) = x86_64 ] && echo USE_64=1) \
  $([ -f /usr/include/sqlite3.h ] && echo NSS_USE_SYSTEM_SQLITE=1)
	cd ../dist                                                          &&

	install -v -m755 Linux*/lib/*.so              /usr/lib              &&
	install -v -m644 Linux*/lib/{*.chk,libcrmf.a} /usr/lib              &&

	install -v -m755 -d                           /usr/include/nss      &&
	cp -v -RL {public,private}/nss/*              /usr/include/nss      &&

	install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} /usr/bin &&

	install -v -m644 Linux*/lib/pkgconfig/nss.pc  /usr/lib/pkgconfig

;;

"nspr")
	
	O &&\
	SRC=$SRC/nspr &&\
	CA --prefix=/usr --disable-static --with-mozilla  \
            --with-pthreads \
            $([ $(uname -m) = x86_64 ] && echo --enable-64bit)
;;

"pciutils")
	O && BD && sed -r '/INSTALL/{/PCI_IDS|update-pciids /d; s/update-pciids.8//}' \
    -i Makefile &&\
    make PREFIX=/usr SHAREDIR=/usr/share/hwdata SHARED=yes &&\
    make PREFIX=/usr SHAREDIR=/usr/share/hwdata SHARED=yes install install-lib &&\
    chmod -v 755 /usr/lib/libpci.so
;;

"hwdata")
	O && CF --prefix=/usr --disable-blacklist && make install
;;
"lsof")
	$r
;;

"zip")
	O && BD && make -f unix/Makefile generic CC="gcc -std=gnu89" &&\
	make prefix=/usr -f unix/Makefile install
;;
"unzip")

	O && BD &&
	CFLAGS="-Wno-error=implicit-function-declaration -Wno-error=implicit-int" \
	 make -f unix/Makefile generic CC="gcc -std=gnu89" &&\
	make prefix=/usr MANDIR=/usr/share/man/man1 -f unix/Makefile install
;;


"pcre2") $r --enable-unicode                    \
            --enable-jit                        \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz             \
            --enable-pcre2grep-libbz2           \
            --enable-pcre2test-libreadline      \
            --disable-static  ;;



"libsecret")
	$mur  -D gtk_doc=false -D crypto=gnutls -D vapi=false -D manpage=false
;;

"nettle") $rds && chmod   -v   755 /usr/lib/lib{hogweed,nettle}.so  ;;


"llvm")
	O llvm-cmake &&\
	O llvm-third-party &&\
	O &&\
	mv $SDIR/llvm-cmake $SDIR/$SRC &&\
	mv $SDIR/llvm-third-party $SDIR/$SRC &&\
	sed '/LLVM_COMMON_CMAKE_UTILS/s@../cmake@llvm-cmake@'          \
    -i CMakeLists.txt                                                 &&\
	sed '/LLVM_THIRD_PARTY_DIR/s@../third-party@llvm-third-party@' \
    -i cmake/modules/HandleLLVMOptions.cmake &&\
    WBD && BD &&\
    CC=gcc CXX=g++ &&\
    cmake -D CMAKE_INSTALL_PREFIX=/usr           \
      -D CMAKE_SKIP_INSTALL_RPATH=ON         \
      -D LLVM_ENABLE_FFI=ON                  \
      -D CMAKE_BUILD_TYPE=Release            \
      -D LLVM_BUILD_LLVM_DYLIB=ON            \
      -D LLVM_LINK_LLVM_DYLIB=ON             \
      -D LLVM_ENABLE_RTTI=ON                 \
      -D LLVM_TARGETS_TO_BUILD="host;AMDGPU" \
      -D LLVM_BINUTILS_INCDIR=/usr/include   \
      -D LLVM_INCLUDE_BENCHMARKS=OFF         \
      -D CLANG_DEFAULT_PIE_ON_LINUX=ON       \
      -D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang \
      -W no-dev -G Ninja $SDIR/$SRC                  &&
ninja && ninja install ;;

"rustc")
O &&\
cat << EOF > config.toml
# see config.toml.example for more possible options
# See the 8.4 book for an old example using shipped LLVM
# e.g. if not installing clang, or using a version before 13.0

# Tell x.py the editors have reviewed the content of this file
# and updated it to follow the major changes of the building system,
# so x.py will not warn us to do such a review.
change-id = 129295

[llvm]
# by default, rust will build for a myriad of architectures
targets = "X86"

# When using system llvm prefer shared libraries
link-shared = true

[build]
# omit docs to save time and space (default is to build them)
docs = false

# install extended tools: cargo, clippy, etc
extended = true

# Do not query new versions of dependencies online.
locked-deps = true

# Specify which extended tools (those from the default install).
tools = ["cargo", "clippy", "rustdoc", "rustfmt", ]

# Use the source code shipped in the tarball for the dependencies.
# The combination of this and the "locked-deps" entry avoids downloading
# many crates from Internet, and makes the Rustc build more stable.
vendor = true

[install]
prefix = "/opt/rustc-1.82.0"
docdir = "share/doc/rustc-1.82.0"

[rust]
channel = "stable"
description = "for codeclub r1"

# Enable the same optimizations as the official upstream build.
lto = "thin"
codegen-units = 1
codegen-tests = false

[target.x86_64-unknown-linux-gnu]
# NB the output of llvm-config (i.e. help options) may be
# dumped to the screen when config.toml is parsed.
llvm-config = "/usr/bin/llvm-config"

[target.i686-unknown-linux-gnu]
# NB the output of llvm-config (i.e. help options) may be
# dumped to the screen when config.toml is parsed.
llvm-config = "/usr/bin/llvm-config"
EOF

sed '/MirOpt/d' -i src/bootstrap/src/core/builder.rs &&

sed 's/!path.ends_with("cargo")/true/' \
    -i src/bootstrap/src/core/build_steps/tool.rs &&

sed 's/^.*build_wasm.*$/#[allow(unreachable_code)]&return false;/' \
    -i src/bootstrap/src/lib.rs

[ ! -e /usr/include/libssh2.h ] || export LIBSSH2_SYS_USE_PKG_CONFIG=1
[ ! -e /usr/include/sqlite3.h ] || export LIBSQLITE3_SYS_USE_PKG_CONFIG=1

python3 x.py build &&\

python3 x.py install rustc std &&\
python3 x.py install --stage=1 cargo clippy rustfmt 
;;

"cargo-c")

[ ! -e /usr/include/libssh2.h ] || export LIBSSH2_SYS_USE_PKG_CONFIG=1    
[ ! -e /usr/include/sqlite3.h ] || export LIBSQLITE3_SYS_USE_PKG_CONFIG=1 

O && PATH=$PATH:/opt/rustc-1.82.0/bin/ CARGO_HTTP_CAINFO=/etc/ssl/certs/bundle.crt cargo build --release && 
install -vm755 target/release/cargo-{capi,cbuild,cinstall,ctest} /usr/bin/ && DI
;;


"sqlite")
	$r --disable-static  \
            --enable-fts{4,5} \
            CPPFLAGS="-DSQLITE_ENABLE_COLUMN_METADATA=1 DSQLITE_SECURE_DELETE=1"   
;;

"libuv") O && ./autogen.sh && CA --prefix=/usr --disable-static;;

"harfbuzz") $mur -D graphite2=enabled ;;
"libxml2") $r --sysconfdir=/etc       \
            --disable-static        \
            --with-history          \
            --with-icu              \
            PYTHON=/usr/bin/python3 && MD &&
		rm -vf /usr/lib/libxml2.la &&\
		sed '/libs=/s/xml2.*/xml2"/' -i /usr/bin/xml2-config 
		;;
"graphite2")
	O &&
	sed -i '/cmptest/d' tests/CMakeLists.txt &&\
	WBD && BD && cmake -D CMAKE_INSTALL_PREFIX=/usr $SDIR/$SRC &&
	MO && MI
;;	
"pango") $mur --wrap-mode=nofallback ;;	
"fribidi") $mur ;;
"dbus") $r --sysconfdir=/etc                    \
            --localstatedir=/var                 \
            --runstatedir=/run                   \
            --disable-doxygen-docs               \
            --disable-xml-docs                   \
            --disable-static                     \
            --with-systemduserunitdir=no         \
            --with-systemdsystemunitdir=no       \
            --with-system-socket=/run/dbus/system_bus_socket ;;

"iptables") $r --disable-nftables --enable-libiq ;;

"alsa-lib") $r && O alsa-ucm-conf && tar -C /usr/share/alsa --strip-components=1 -xf $LDIR/alsa-ucm-conf-1.2.12.tar.bz2 ;;
"alsa-plugins") $r --sysconfdir=/etc ;;
"alsa-utils") $r --disable-alsaconf \
            --disable-bat      \
            --disable-xmlto    \
            --with-curses=ncursesw ;;

"flac") $r --disable-thorough-tests ;;
"pulseaudio") $mur --buildtype=release \
            -D database=gdbm    \
            -D doxygen=false    \
            -D bluez5=disabled  ;;


"p11-kit")
	$mur --buildtype=release \
      -D trust_paths=/etc/pki/anchors &&\
      
      ln -sfv /usr/libexec/p11-kit/trust-extract-compat \
        /usr/bin/update-ca-certificates
;;

"fuse") $mur --buildtype=release ;;
"fuse2")

		O && ./configure --prefix=/usr    \
            --disable-static \
            --exec-prefix=/  &&

		MO &&
		MIA="DESTDIR=$PWD/Dest"
		MI &&
		
		install -vm755 Dest/lib/libfuse.so.2.9.9 /lib                  &&
		install -vm755 Dest/lib/libulockmgr.so.1.0.1 /lib                 &&
		ln -sfv ../../lib/libfuse.so.2.9.9 /usr/lib/libfuse.so         &&
		ln -sfv ../../lib/libulockmgr.so.1.0.1 /usr/lib/libulockmgr.so &&

		install -vm644  Dest/lib/pkgconfig/fuse.pc /usr/lib/pkgconfig  && 
																 
		install -vm4755 Dest/bin/fusermount       /bin                 &&
		install -vm755  Dest/bin/ulockmgr_server  /bin                 &&

		install -vm755  Dest/sbin/mount.fuse      /sbin                &&

		install -vdm755 /usr/include/fuse                              &&

		install -vm644  Dest/usr/include/*.h      /usr/include         &&
		install -vm644  Dest/usr/include/fuse/*.h /usr/include/fuse/   


;;

*) 

	if [[ "$ITEM" == *-32 ]]; then
		R32
	else
		$r
	fi
	
;;


esac
