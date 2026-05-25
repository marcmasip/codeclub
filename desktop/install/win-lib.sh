at_x(){
	at https://www.x.org/pub/individual/lib/$src-$1.tar.xz
	return $?
}
xlib(){
	at_x $1 &&  $rx && make distclean && r32
	return $?
}
xapp(){
	at https://www.x.org/pub/individual/app/$src-$1.tar.xz &&  $rxs
	return $?
}

ins_libpng(){
	at  https://downloads.sourceforge.net/libpng/libpng-1.6.50.tar.xz && $r && make clean && r32
	return $?
}

ins_freetype(){
	at https://downloads.sourceforge.net/freetype/freetype-2.14.1.tar.xz &&\
	o && bd && sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg &&

sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
    -i include/freetype/config/ftoption.h  &&

ca --prefix=/usr --enable-freetype-config --disable-static &&\
	make clean &&
	cf32 --prefix=/usr --enable-freetype-config --disable-static && mo && mi32

	return $?
}
ins_wmctrl(){
	at https://manned.org/pkg/arch/wmctrl/1.07-6 && $r	
	return $?
}


ins_fontconfig(){
	 at https://gitlab.freedesktop.org/api/v4/projects/890/packages/generic/fontconfig/2.17.1/fontconfig-2.17.1.tar.xz &&\
	 $r --sysconfdir=/etc    \
            --localstatedir=/var \
            --disable-docs       \
            --docdir=/usr/share/doc/fontconfig-2.17.1
	 return $?
}

ins_util_macros(){
	at https://www.x.org/pub/individual/util/util-macros-1.20.2.tar.xz && $rx
	return $?
}

ins_xorgproto(){
	at https://xorg.freedesktop.org/archive/individual/proto/xorgproto-2024.1.tar.xz && $mu
	return $?
}
ins_libXau() {
    at https://www.x.org/pub/individual/lib/libXau-1.0.12.tar.gz && \
    $r && make distclean && r32
    return $?
}
ins_libXdmcp() {
    at https://www.x.org/pub/individual/lib/libXdmcp-1.1.5.tar.gz && \
    $rx && make distclean && r32
    return $?
}
ins_xcb_proto(){
	 at https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-1.17.0.tar.xz && $rx
	return $?
}
ins_libxcb() {
    at https://xorg.freedesktop.org/archive/individual/lib/libxcb-1.17.0.tar.xz && \
    $rx --without-doxygen && make distclean && r32 --without-doxygen
    return $?
}
ins_xtrans() {
    at https://www.x.org/pub/individual/lib/xtrans-1.6.0.tar.gz && \
    $rx 
    return $?
}
ins_libX11() {
    at https://www.x.org/pub/individual/lib/libX11-1.8.12.tar.gz && \
    $rx && make distclean && r32 
    return $?
}

ins_libXext() {
    at https://www.x.org/pub/individual/lib/libXext-1.3.6.tar.gz && \
    $rx && make distclean && r32
    return $?
}
ins_libFS() {
    at https://www.x.org/pub/individual/lib/libFS-1.0.10.tar.gz && \
    $rx && make distclean && r32
    return $?
}
ins_libICE() {
    at_x 1.0.10 && $rx && make distclean && r32
    return $?
}
ins_libSM() {
    xlib 1.2.6
    return $?
}
ins_libXScrnSaver(){
	xlib 1.2.5
	return $?
}
ins_libXt(){
	xlib 1.3.1
	return $?
}
ins_libXmu(){
	xlib 1.2.1
	return $?
}
ins_libXpm(){
	xlib 3.5.17
	return $?
}
ins_libXaw(){
	xlib 1.0.16
	return $?
}
ins_libXfixes(){
	xlib 6.0.2
	return $?
}
ins_libXcomposite(){
	xlib 0.4.6
	return $?
}
ins_libXrender(){
	xlib 0.9.12
	return $?
}
ins_libXcursor(){
	xlib 1.2.3
	return $?
}
ins_libXdamage(){
	xlib 1.1.6
	return $?
}
ins_libfontenc(){
	xlib 1.1.8
	return $?
}
ins_libXfont2(){
	xlib 2.0.7
	return $?
}
ins_libXft(){
	xlib 2.3.9
	return $?
}
ins_libXi(){
	xlib 1.8.2
	return $?
}
ins_libXinerama(){
	xlib 1.1.5
	return $?
}
ins_libXrandr(){
	xlib 1.5.4
	return $?
}
ins_libXres(){
	xlib 1.2.3
	return $?
}
ins_libXtst(){
	xlib 1.2.5
	return $?
}
ins_libXv(){
	xlib 1.0.13
	return $?
}
ins_libXvMC(){
	xlib 1.0.14
	return $?
}
ins_libXxf86dga(){
	xlib 1.1.6
	return $?
}

ins_libXxf86vm(){
	xlib 1.1.6
	return $?
}
ins_libpciaccess(){
	
	at_x 0.18.1 &&  $mu && $mu32
	return $?
}
ins_libxkbfile(){
	xlib 1.1.3
	return $?
}
ins_libxshmfence(){
	xlib 1.3.3
	return $?
}
ins_libXpresent(){
	xlib 1.0.2
	return $?
}
ins_libxcvt(){
	at_x 0.1.3  &&  $mu && $mu32
	return $?
}

ins_xcb_util(){
	src="xcb-util"
	at https://xcb.freedesktop.org/dist/xcb-util-0.4.1.tar.xz && $rx && make distclean && r32
	return $?
}

ins_xcbutilimage(){
	src="xcb-util-image"
	xlib 0.4.1
	return $?
}
ins_xcbutilkeysyms(){
	src="xcb-util-keysyms"
	xlib 0.4.1
	return $?
}
ins_xcbutilrenderutil(){
	src="xcb-util-renderutil"
	xlib 0.3.10
	return $?
}
ins_xcbutilwm(){
	src="xcb-util-wm"
	xlib 0.4.2
	return $?
}

ins_xcbutilcursor(){
	src="xcb-util-cursor"
	xlib 0.1.6
	return $?
}





ins_mingw_headers() {
    # mingw-w64 vive en sourceforge
    src="mingw-w64"
    at https://github.com/mingw-w64/mingw-w64/archive/refs/tags/v13.0.0.tar.gz 13.0.0 &&\
    o && wbd
    
    # el configure está en un subdirectorio
    cd "$bdir/$src"
    "$sdir/$src/mingw-w64-headers/configure" \
        --prefix=$prefix \
        --host=$otar
        
    mo && mi
}
ins_mingw_w64(){
	at https://github.com/mingw-w64/mingw-w64/archive/refs/tags/v13.0.0.tar.gz 13.0.0 &&\
	o && wbd && bd && ca --prefix=/usr --enable-lib32 --enable-lib64 --enable-experimental --host=x86_64-w64-mingw32
	
	return $?
}

ins_xbitmaps(){
	at  https://www.x.org/pub/individual/data/xbitmaps-1.1.3.tar.xz &&\
	o && cf --prefix=/usr && mi
	return $?
}


ins_iceauth(){
	xapp 1.0.10
	return $?
}

ins_mkfontscale(){
    xapp 1.2.3
    return $?
}

ins_sessreg(){
    xapp 1.1.4
    return $?
}

ins_setxkbmap(){
    xapp 1.3.4
    return $?
}

ins_smproxy(){
    xapp 1.0.8
    return $?
}

ins_xauth(){
    xapp 1.1.4
    return $?
}

ins_xcmsdb(){
    xapp 1.0.7
    return $?
}

ins_xcursorgen(){
    xapp 1.0.9
    return $?
}

ins_xdpyinfo(){
    xapp 1.4.0
    return $?
}

ins_xdriinfo(){
    xapp 1.0.8
    return $?
}

ins_xev(){
    xapp 1.2.6
    return $?
}

ins_xgamma(){
    xapp 1.0.8
    return $?
}

ins_xhost(){
    xapp 1.0.10
    return $?
}

ins_xinput(){
    xapp 1.6.4
    return $?
}

ins_xkbcomp(){
    xapp 1.4.7
    return $?
}

ins_xkbevd(){
    xapp 1.1.6
    return $?
}

ins_xkbutils(){
    xapp 1.0.6
    return $?
}

ins_xkill(){
    xapp 1.0.6
    return $?
}

ins_xlsatoms(){
    xapp 1.1.4
    return $?
}

ins_xlsclients(){
    xapp 1.1.5
    return $?
}

ins_xmessage(){
    xapp 1.0.7
    return $?
}

ins_xmodmap(){
    xapp 1.0.11
    return $?
}

ins_xpr(){
    xapp 1.2.0
    return $?
}

ins_xprop(){
    xapp 1.2.8
    return $?
}

ins_xrandr(){
    xapp 1.5.3
    return $?
}

ins_xrdb(){
    xapp 1.2.2
    return $?
}

ins_xrefresh(){
    xapp 1.1.0
    return $?
}

ins_xset(){
    xapp 1.2.5
    return $?
}

ins_xsetroot(){
    xapp 1.1.3
    return $?
}

ins_xvinfo(){
    xapp 1.1.5
    return $?
}

ins_xwd(){
    xapp 1.0.9
    return $?
}

ins_xwininfo(){
    xapp 1.1.6
    return $?
}

ins_xwud(){
    xapp 1.0.7
    return $?
}

ins_xcursor_themes(){
	at  https://www.x.org/pub/individual/data/xcursor-themes-1.0.7.tar.xz && oa --prefix=/usr
	return $?
}


xfont() {
    local v=$1
    local u="https://www.x.org/pub/individual/font/$src-$v.tar.xz"
    
    at "$u" "$v"
    oa --prefix=/usr
    return $?
}

ins_font_util() {
    xfont 1.4.1
    return $?
}

ins_encodings() {
    xfont 1.1.0
    return $?
}

ins_font_alias() {
    xfont 1.0.5
    return $?
}

ins_font_adobe_utopia_type1() {
    xfont 1.0.5
    return $?
}

ins_font_bh_ttf() {
    xfont 1.0.4
    return $?
}

ins_font_bh_type1() {
    xfont 1.0.4
    return $?
}

ins_font_ibm_type1() {
    xfont 1.0.4
    return $?
}

ins_font_misc_ethiopic() {
    xfont 1.0.5
    return $?
}

ins_font_xfree86_type1() {
    xfont 1.0.5
    return $?
}



ins_xorg_server(){
	at https://www.x.org/pub/individual/xserver/xorg-server-21.1.18.tar.xz &&\
	$mur  --localstatedir=/var   \
      -D glamor=true         \
      -D dri3=true \
      -D udev=true \
      -D dtrace=false \
      -D xkb_output_dir=/var/lib/xkb
    return $?
}




ins_xkeyboard_config(){
	at  https://www.x.org/pub/individual/data/xkeyboard-config/xkeyboard-config-2.45.tar.xz && $mur
}


ins_luit(){
	at https://invisible-mirror.net/archives/luit/luit-20240910.tgz &&\
	$rx
	return $?
}
	




# 2. librería de lógica (gestos, aceleración, etc)
ins_libinput() {
    at " https://gitlab.freedesktop.org/libinput/libinput/-/archive/1.29.0/libinput-1.29.0.tar.gz" &&\
    $mur -Ddocumentation=false -Dtests=false -Ddebug-gui=false -Dlibwacom=false -Dudev-dir=/usr/lib/udev
   return $?
}
ins_xf86_video_fbdev() {
	at https://www.x.org/pub/individual/driver/xf86-video-fbdev-0.5.0.tar.bz2 &&\
	$rx
	return $?
}
ins_xf86_input_evdev() {
    at "https://www.x.org/pub/individual/driver/xf86-input-evdev-2.11.0.tar.xz" && $rx
    return $?
}

ins_xf86_input_synaptics(){
	at  https://www.x.org/pub/individual/driver/xf86-input-synaptics-1.10.0.tar.xz && $rx
	
	return $?
}

# 3. el "pegamento" para el servidor xorg
ins_xf86_input_libinput() {
    at "https://www.x.org/archive/individual/driver/xf86-input-libinput-1.4.0.tar.xz" && $rx
    return $?
}


ins_xf86_video_intel(){
	at  https://anduin.linuxfromscratch.org/BLFS/xf86-video-intel/xf86-video-intel-20210222.tar.xz &&\

		 $mur -Dvalgrind=false -Dkms=true -Dums=false -Dxvmc=false
	return $?
	
}


# SOUND?

ins_flac(){
	 at https://github.com/xiph/flac/releases/download/1.5.0/flac-1.5.0.tar.xz && $rx --disable-thorough-tests
	 return $?
 }
	 

ins_libsndfile(){
	at https://github.com/libsndfile/libsndfile/releases/download/1.2.2/libsndfile-1.2.2.tar.xz && o &&\
	sed '/typedef enum/,/bool ;/d' -i src/ALAC/alac_{en,de}coder.c &&\
	ca --prefix=/usr	
	return $?
	
}

ins_gtk() {
	at  https://download.gnome.org/sources/gtk/3.24/gtk-3.24.51.tar.xz &&\
  $mur -Dman=false -Dbroadway_backend=true -Dwayland_backend=false
  return $?
}

ins_glib() {
  at  https://download.gnome.org/sources/glib/2.86/glib-2.86.1.tar.xz &&\
  $mur \
    -Dglib_debug=disabled \
    -Dsysprof=disabled
  return $?
}

ins_gobject_introspection() {
  at  https://download.gnome.org/sources/gobject-introspection/1.86/gobject-introspection-1.86.0.tar.xz &&\
  $mur -Dtests=false
  return $?
}

# esto asume que el item se llama 'glib2' pero el 'src' es 'glib'
ins_glib2() {
  at  https://download.gnome.org/sources/glib/2.86/glib-2.86.1.tar.xz &&\
  $mur \
    -Dglib_debug=disabled \
    -Dsysprof=disabled
  return $?
}

ins_pango(){
	at https://download.gnome.org/sources/pango/1.57/pango-1.57.0.tar.xz &&\
	$mur --wrap-mode=nofallback   \
            -D introspection=enabled
    return $?
}


ins_xdotool() {
  o && \+
  bd && \
  mo PREFIX=/usr && \
  mi PREFIX=/usr
  return $?
}
ins_tumbler(){
	at https://archive.xfce.org/src/xfce/tumbler/4.20/tumbler-4.20.1.tar.bz2 && $r
	return $?
}


ins_shared_mime_info() {
	 at https://gitlab.freedesktop.org/xdg/shared-mime-info/-/archive/2.4/shared-mime-info-2.4.tar.gz &&\
  $mur -Dupdate-mimedb=true
  return $?
}

ins_icu(){
	at https://github.com/unicode-org/icu/releases/download/release-77-1/icu4c-77_1-src.tgz &&\
	o && bd && cd source && ./configure --prefix=/usr && make && make install
	
	return $?
	
}

ins_libxml2(){
	at https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.1.tar.xz &&\
	$r --sysconfdir=/etc       \
            --disable-static        \
            --with-history          \
            --with-icu              \
            PYTHON=/usr/bin/python3 && 
		rm -vf /usr/lib/libxml2.la &&\
		sed '/libs=/s/xml2.*/xml2"/' -i /usr/bin/xml2-config 
}
ins_pcre2() {
  oa --enable-unicode \
    --enable-jit \
    --enable-pcre2-16 \
    --enable-pcre2-32 \
    --enable-pcre2grep-libz \
    --enable-pcre2grep-libbz2 \
    --enable-pcre2test-libreadline \
    --disable-static
  return $?
}

ins_gdk_pixbuf() {
	at https://download.gnome.org/sources/gdk-pixbuf/2.44/gdk-pixbuf-2.44.2.tar.xz &&\
  $mur -Dman=false -Dothers=enabled --wrap-mode=nofallback  -Dglycin=disabled
  return $?
}

ins_graphite2() {
  o && \
  sed -i '/cmptest/d' tests/CMakeLists.txt && \
  wbd && \
  bd && \
  cmake -DCMAKE_INSTALL_PREFIX=/usr "$sdir/$src" && \
  mo && \
  mi
  return $?
}

ins_atk() {
  mes
  return $?
}

ins_libjpeg_turbo() {
  o && \
  wbd && \
  bd && \
  cmake -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DENABLE_STATIC=FALSE \
    -DCMAKE_INSTALL_DEFAULT_LIBDIR=lib \
    -DCMAKE_SKIP_INSTALL_RPATH=ON \
    "$sdir/$src" && \
  mo && \
  mi && \
  di
  return $?
}

ins_at_spi2_core() {
	at https://download.gnome.org/sources/at-spi2-core/2.58/at-spi2-core-2.58.1.tar.xz &&\
  $mur  -D gtk2_atk_adaptor=false \
      -D systemd_user_dir=/tmp 
  return $?
}

ins_at_spi2_atk() {
  mes
  return $?
}

ins_dbus(){
	at  https://dbus.freedesktop.org/releases/dbus/dbus-1.16.2.tar.xz &&\
	$mur  --wrap-mode=nofallback \
            -D systemd=disabled 
	return $?
            
		}

ins_fribidi() {
  at  https://github.com/fribidi/fribidi/releases/download/v1.0.16/fribidi-1.0.16.tar.xz && $mur
  return $?
}
ins_libxkbcommon(){
	
	 at https://github.com/lfs-book/libxkbcommon/archive/v1.12.1/libxkbcommon-1.12.1.tar.gz &&\
	 $mur -Denable-wayland=false
	 return $?
	 
 }

ins_xfconf(){
	at  https://archive.xfce.org/src/xfce/xfconf/4.20/xfconf-4.20.0.tar.bz2 && $rx
	
	return $?
}

ins_libxfce4util(){
	at https://archive.xfce.org/src/xfce/libxfce4util/4.20/libxfce4util-4.20.1.tar.bz2 && $rx
	return $?
}
ins_libxfce4ui(){
	at https://archive.xfce.org/src/xfce/libxfce4ui/4.20/libxfce4ui-4.20.2.tar.bz2 &&\
	$rx --sysconfdir=/etc
	
	return $?
	
}



ins_harfbuzz(){
	at  https://github.com/harfbuzz/harfbuzz/releases/download/12.1.0/harfbuzz-12.1.0.tar.xz &&\
	$mur && $mu32
	return $?
	
}



ins_exo(){
	at  https://archive.xfce.org/src/xfce/exo/4.20/exo-4.20.0.tar.bz2 && $rx --sysconfdir=/etc
	return $?
}

ins_Linux_PAM(){
	at https://github.com/linux-pam/linux-pam/releases/download/v1.7.1/Linux-PAM-1.7.1.tar.xz &&\
	$mur -Ddocs=disabled
	return $?
}
	



ins_hicolor_icon_theme(){
	 at https://icon-theme.freedesktop.org/releases/hicolor-icon-theme-0.17.tar.xz && o && cf --prefix=/usr && mi && di
	 return $?
}


ins_libva(){
	at https://github.com/intel/libva/releases/download/2.23.0/libva-2.23.0.tar.bz2 && $rx
	return $?
}	
ins_libva_utils(){
	at https://github.com/intel/libva-utils/releases/download/2.23.0/libva-utils-2.23.0.tar.bz2 && $rx
	return $?
}

ins_libxkbfile() {
    at https://www.x.org/pub/individual/lib/libxkbfile-1.1.3.tar.gz && \
    o && ./configure --help | more ; exit
    $r && make distclean && r32
    return $?
}

ins_librsvg(){
	at https://download.gnome.org/sources/librsvg/2.61/librsvg-2.61.3.tar.xz &&\
	PATH=$PATH:/opt/rustc-1.91.0/bin/ $mur -Dpixbuf-loader=enabled --buildtype=release 
	 return $?
}

ins_libev(){
	at https://dist.schmorp.de/libev/libev-4.33.tar.gz && $rx
	return $?
}


ins_libaom(){
	at  https://storage.googleapis.com/aom-releases/libaom-3.13.3.tar.gz &&\
	cmn -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release -D BUILD_SHARED_LIBS=1       \
      -D ENABLE_DOCS=no
    return $?
}
ins_libass(){
	at  https://github.com/libass/libass/releases/download/0.17.4/libass-0.17.4.tar.xz && $r
	return $?
}
ins_fdk_aac(){
	at https://downloads.sourceforge.net/opencore-amr/fdk-aac-2.0.3.tar.gz && $r
	return $?
}
ins_lame(){
	at https://downloads.sourceforge.net/lame/lame-3.100.tar.gz && $r --enable-mp3rtp --disable-static 
	return $?
}
ins_libvorbis(){
	at https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.xz && $r
	return $?
}
ins_libogg(){
	at https://downloads.xiph.org/releases/ogg/libogg-1.3.6.tar.xz && $r
	return $?
}
ins_libvpx(){
	 at https://github.com/webmproject/libvpx/archive/refs/tags/v1.16.0.tar.gz 1.16.0 tar.gz  && o && wbd && ca --prefix=/usr    \
             --enable-shared  \
             --disable-static \
             --as=yasm
	 return $?
 }
ins_x264(){
	at  https://anduin.linuxfromscratch.org/BLFS/x264/x264-20250815.tar.xz && $r --enable-shared \
            --disable-cli  
	return $?
}
ins_opus(){
	at http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz && $r
	return $?
	
}

ins_x265(){
	at https://bitbucket.org/multicoreware/x265_git/downloads/x265_4.2.tar.gz 4.2 tar.gz x265_4.2  &&\
            o && wbd && bd &&
cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D GIT_ARCHETYPE=1           \
      -W no-dev $sdir/$at_name/source
make &&\
make install &&\
rm -vf /usr/lib/libx265.a 
	return $?
}
ins_SDL2(){
	at https://www.libsdl.org/release/SDL2-2.0.14.tar.gz && $r
	return $?
}
ins_dav1d(){
	at https://code.videolan.org/videolan/dav1d/-/archive/1.5.3/dav1d-1.5.3.tar.gz && $mur
	return $?
}
ins_ffmpeg(){
	at https://ffmpeg.org/releases/ffmpeg-8.1.tar.xz &&\
	$r --disable-static \
    --enable-shared \
    --enable-gpl \
    --enable-version3 \
    --enable-nonfree \
    --disable-debug \
    --enable-libaom \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-openssl \
    --enable-ffmpeg \
    --ignore-tests=enhanced-flv-av1 \
    --enable-vaapi \
    --enable-vdpau \
    --enable-libdrm \
    --enable-libdav1d
    return $?
}
ins_gsettings_desktop_schemas(){
	at https://download.gnome.org/sources/gsettings-desktop-schemas/50/gsettings-desktop-schemas-50.1.tar.xz &&\
	o && bd && sed -i -r 's:"(/system):"/org/gnome\1:g' schemas/*.in &&

mkdir build &&
cd    build &&

meson setup --prefix=/usr --buildtype=release .. &&
ninja && ninja install

	return $?
}
ins_imlib2(){
	at https://downloads.sourceforge.net/enlightenment/imlib2-1.12.6.tar.xz && $r
	
	
	return $?
}
	
run_item
