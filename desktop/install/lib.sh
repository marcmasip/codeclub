#!/usr/bin/env bash

. conf.sh
. $ldir/script/show.sh
. macro.sh


ins_libssh2(){
	at https://www.libssh2.org/download/libssh2-1.11.1.tar.gz &&\
	$r -disable-docker-tests \
            --disable-static
	return $?
}

ins_rustc() {
at https://static.rust-lang.org/dist/rustc-1.91.0-src.tar.xz 1.91.0-src && o && bd &&\
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


ins_libconfig(){
	at "https://github.com/hyperrealm/libconfig/archive/refs/tags/v1.8.2.tar.gz" 1.8.2 && o && autoreconf && ca
	return $?
}
ins_uthash(){
	at "https://github.com/troydhanson/uthash/archive/refs/tags/v2.3.0.tar.gz" 2.3.0 && o && cp src/*.h /usr/include
	return $?
}



run_item
