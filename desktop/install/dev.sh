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

ins_patch(){
	at_gnu 2.8 && $r
	return $?
}
ins_diffutils(){
    # Utilidades para comparar ficheros, esencial para parches y desarrollo.
    at_gnu 3.12 && $r
    return $?
}
ins_make(){
	at_gnu 4.4.1 && $r
	return $?
}
ins_m4(){
	ato gnu 1.4.20 &&\
	sed 's/\[\[__nodiscard__]]//' -i lib/config.hin &&\
	sed 's/test-stdalign\$(EXEEXT) //' -i tests/Makefile.in &&\
	cf --prefix=/usr && mo && mi && di
	return $?
}
ins_autoconf(){
	at_gnu 2.72 && oa 
	return $?
}
ins_automake(){
    # Crea 'Makefile.in' para ser usados por Autoconf.
    at_gnu 1.18.1 && oa
    return $?
}
ins_texinfo(){
	at_gnu 7.2 && o && sed 's/! $output_file eq/$output_file ne/' -i tp/Texinfo/Convert/*.pm && $r
	return $?
}


ins_bison(){
	at_gnu 3.8.2 && oa
}
ins_flex(){
	 at https://github.com/westes/flex/files/981163/flex-2.6.4.tar.gz
	 oa --with-gnu-ld --enable-shared 
	 return $?
}

ins_pkgconf(){
	at https://distfiles.ariadne.space/pkgconf/pkgconf-2.5.1.tar.xz 
	oa &&\
	ln -sv pkgconf   /usr/bin/pkg-config &&\
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


ins_gettext(){
	at_gnu 0.26 && oa
	return $?
}
ins_xml_parser(){
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

ins_gperf(){
    # Generador de funciones hash perfectas, usado por muchos paquetes.
    at_gnu 3.3 && $r
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

ins_sqlite(){
    # Motor de base de datos SQL embebido.
    src="sqlite-autoconf"
    # Activamos FTS5, una extensión muy útil para búsqueda de texto completo.
    at https://www.sqlite.org/2025/sqlite-autoconf-3500400.tar.gz &&\
    CFLAGS="-DSQLITE_ENABLE_FTS5" $rud && make distclean &&\
    CFLAGS="-m32 -DSQLITE_ENABLE_FTS5" r32 --disable-static --host=i686-pc-linux-gnu
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

ins_python(){
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


ins_git(){
	at https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.51.0.tar.gz &&\
	$r --with-openssl --without-tcltk
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

ins_lua(){
	at https://lua.org/ftp/lua-5.5.0.tar.gz && o && bd &&\
	make all test install
	return $?
}

ins_yasm(){
	at https://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz && $r
	return $?
}
ins_nasm(){
	at https://www.nasm.us/pub/nasm/releasebuilds/3.01/nasm-3.01.tar.xz &&\
	$r
	return $?
}




ins_rustc() {
at https://static.rust-lang.org/dist/rustc-1.91.0-src.tar.xz 1.91.0-src && o && bd &&\
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
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
# many crates from Internet, and makes the rustc build more stable.
vendor = true

[install]
prefix = "/opt/rustc-1.91.0"
docdir = "share/doc/rustc-1.91.0"

[rust]
channel = "stable"

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
	
	return $?
        
}
ins_cargo_c(){
	
[ ! -e /usr/include/libssh2.h ] || export LIBSSH2_SYS_USE_PKG_CONFIG=1    
[ ! -e /usr/include/sqlite3.h ] || export LIBSQLITE3_SYS_USE_PKG_CONFIG=1 
at https://github.com/lu-zero/cargo-c/archive/v0.10.18/cargo-c-0.10.18.tar.gz &&\
o && PATH=$PATH:/opt/rustc-1.91.0/bin/ cargo build --release && 
install -vm755 target/release/cargo-{capi,cbuild,cinstall,ctest} /usr/bin/ && DI


}
