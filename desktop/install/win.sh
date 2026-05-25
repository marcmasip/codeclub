# TOOLS
ins_xclip() {
	at https://github.com/astrand/xclip/archive/refs/tags/0.13.tar.gz 0.13 tar.gz &&
	oa
}
ins_picom(){
	at  "https://github.com/yshui/picom/archive/refs/tags/v13.tar.gz" 13 &&
	oa
}

ins_jwm(){
	at https://github.com/joewing/jwm/releases/download/v2.4.6/jwm-2.4.6.tar.xz && $rx
	return $?
}
ins_conky(){
	at https://github.com/brndnmtthws/conky/archive/refs/tags/v1.22.3.tar.gz 1.22.3 tar.gz "conky-1.22.3" && o && bd &&\
	sed -i \
  -e 's/LUA_GCSETPAUSE/LUA_GCPPAUSE/g' \
  -e 's/LUA_GCSETSTEPMUL/LUA_GCPSTEPMUL/g' \
  /tmp/club/src/conky/src/lua/luamm.hh
	cmake -S . -B build --fresh &&\
	cmake --build build &&\
	cmake --install build
	return $?
}
ins_xterm(){
	ato https://invisible-mirror.net/archives/xterm/xterm-401.tgz &&\
	sed -i '/v0/{n;s/new:/new:kb=^?:/}' termcap &&\
	printf '\tkbs=\\177,\n' >> terminfo &&\
	TERMINFO=/usr/share/terminfo \
	ca --prefix=/usr --with-app-defaults=/etc/X11/app-defaults &&\
	mkdir -pv /usr/share/applications &&\
	cp -v *.desktop /usr/share/applications/
	return $?
}

ins_thunar(){
	at https://archive.xfce.org/src/xfce/thunar/4.20/thunar-4.20.8.tar.bz2 && $rx --sysconfdir=/etc
	return $?
	
}

ins_wezterm(){
	at "https://github.com/wezterm/wezterm/releases/download/20240203-110809-5046fc22/wezterm-20240203-110809-5046fc22-src.tar.gz" 20240203-110809-5046fc22 tar.gz  &&\ 
	BUILD_OPTS=" --release "
	o && bd && PATH=$PATH:/opt/rustc-1.82.0/bin &&\
	cargo update -p time &&\
	
	cargo build --release --no-default-features --features vendored-fonts \
		-p wezterm-gui -p wezterm  -p wezterm-mux-server -p strip-ansi-escapes &&\
		
	install -Dsm755 target/release/wezterm -t $ODIR/usr/bin &&\
	install -Dsm755 target/release/wezterm-mux-server -t $ODIR/usr/bin &&\
	install -Dsm755 target/release/wezterm-gui -t $ODIR/usr/bin &&\
	install -Dsm755 target/release/strip-ansi-escapes -t $ODIR/usr/bin
	return $?
}



# DEV



ins_virglrenderer(){
	at https://github.com/utmapp/virglrenderer/archive/refs/tags/rel/UTM/v5.0.0.tar.gz "v5.0.0" "tar.gz" "virglrenderer-rel-UTM-v5.0.0" &&\
	CFLAGS="-Wno-error=pedantic -Wno-implicit-function-declaration"  $mur -Dvenus=true
	return $?
}

ins_qemu() {
    # usamos una versión estable reciente
    at "https://download.qemu.org/qemu-9.2.4.tar.xz"

    # quest: retro (i386, x86_64) + iot (arm)
    local targets="i386-softmmu,x86_64-softmmu,arm-softmmu"
    
    # usamos meson. 'mes' (de combo.sh) se encarga de todo el flujo
    # (o, wbd, bd, setup, ninja, ninja install)
    $rxs --sysconfdir=/etc        \
             --localstatedir=/var     \
             --target-list=$targets \
             --audio-drv-list=alsa    \
             --disable-pa             \
             --enable-slirp    --enable-opengl              \
  --enable-virglrenderer       \
  --enable-gtk                 \
  --enable-sdl       
  
}

# TEXTOS
ins_geany() {
  at "https://download.geany.org/geany-2.1.tar.gz" && $r
  return $?
}

ins_thunar_archive_plugin(){
	at "https://github.com/xfce-mirror/thunar-archive-plugin/archive/refs/tags/thunar-archive-plugin-0.6.0.tar.gz" "0.6.0" "tar.gz" "thunar-archive-plugin-thunar-archive-plugin-0.6.0"  && $mur
	return $?
}

# AUDIO
ins_xmms(){
	at "http://www.xmms.org/files/1.2.x/xmms-1.2.10.tar.bz2" "13-rc1" &&\
	$rx
	return $?
}

ins_wine(){
	at https://gitlab.winehq.org/wine/wine/-/releases/wine-11.8/downloads/wine-11.8.tar.xz &&\
	$r
	
	return $?
}

