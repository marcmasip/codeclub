# Base components setup

# Shortcuts

XORG_PREFIX="/usr"
XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc \
    --localstatedir=/var --disable-static"
   
r="OA" 
cx="CF $XORG_CONFIG"
rx="$r $XORG_CONFIG"
ru="$r --prefix=/usr"
rud="$ru --disable-static"
mu="MES --prefix=/usr"
mur="$mu --prefix=$XORG_PREFIX"


# Item plans



case "$ITEM" in


"freetype")	O &&\
	sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg &&\
	sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
    -i include/freetype/config/ftoption.h  &&\
	CF --prefix=/usr --enable-freetype-config --disable-static &&
	MO && MI
;;

"fontconfig") $ru --sysconfdir=/etc --localstatedir=/var --disable-docs ;;
"util-macros") O && CF $XORG_CONFIG && make install ;;
"xorgproto")  $mu ;;
"xorg-server") $mu --localstatedir=/var   \
      -D glamor=true         \
      -D xkb_output_dir=/var/lib/xkb
;;
"xcb-proto") O && PYTHON=python3 $cx && MI && DI ;;
"libxcb") $rx --without-doxgen ;;
"libXpm") $rx --disable-open-zfile ;;
"libXfont2") $rx  --disable-devel-docs ;;
"libpciaccess") $mur ;;
"libpng") $rud ;;
"libdrm") $mur -D udev=true -D valgrind=disabled  ;;
"libvdpau") $mu ;;
"libuv") O && ./autogen.sh && CA --prefix=/usr --disable-static;;

"libarchive") $rud ;;

"glslang") CMN -D CMAKE_INSTALL_PREFIX=/usr     \
      -D CMAKE_BUILD_TYPE=Release      \
      -D ALLOW_EXTERNAL_SPIRV_TOOLS=ON \
      -D BUILD_SHARED_LIBS=ON          \
      -D GLSLANG_TESTS=ON 
;;

"libva") $mur ;;
"libclc") CMN -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release ;;
"MarkupSafe") PIPB MarkupSafe ;;
"Mako") PIPB Mako ;;
"pyyaml") PIPB PyYAML ;;

"wayland") $mur -D documentation=false ;;
"wayland-protocols") $mur ;;
"font-util") $rx ;;
"pixman") $mur ;;
"libxcvt") $mur ;;
"mesa") $mur \
      -D platforms=x11 \
      -D gallium-drivers=r600,softpipe,radeonsi,d3d12 \
      -D vulkan-drivers=amd,swrast  \
      -D glx=auto \
      -D video-codecs=all \
      -D egl-native-platform=x11 \
      -D egl=enabled \
      -D libunwind=disabled ;;  
      
"libepoxy") $mur ;;
"mtdev") $rud ;;
"libevdev") $mur -D documentation=disabled ;;
"libinput") $mur -D debug-gui=false        \
      -D tests=false            \
      -D libwacom=false         \
      -D udev-dir=/usr/lib/udev ;;

"xkeyboard-config") $mur ;;
"libxkbcommon") $mur -D enable-docs=false ;;
"xinit") $rx --with-xinitdir=/etc/X11/app-defaults ;;
"xbitmaps")
	O && CF $XORG_CONFIG && MI
;;


"cairo") $mur ;;

"gls") 	$ru ;;

"font-util") $rx ;;
"pixman") $mur ;;

"gtk3") $mur -D man=false  -D broadway_backend=true ;;
"glib") 

$mur --buildtype=release       \
      -Dintrospection=disabled \
      -Dglib_debug=disabled    \
      -Dsysprof=disabled  
      
      
 ;;

"xdottool")
	O && BD && MO PREFIX=/usr && MI PREFIX=/usr
;;

"gobject-introspection") $mur --buildtype=release -Dtests=false ;;
"glib2") SRC="glib" && $mur --buildtype=release -Dintrospection=enabled ;;



"harfbuzz") $mur -D graphite2=enabled ;;
"shared-mime-info")	$mur -D update-mimedb=true ;;

"pcre2") $ru --enable-unicode                    \
            --enable-jit                        \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz             \
            --enable-pcre2grep-libbz2           \
            --enable-pcre2test-libreadline      \
            --disable-static                    
;;

"gdk-pixbuf") $mur -D man=false -D others=enabled --wrap-mode=nofallback ;;
"graphite2")
	O &&
	sed -i '/cmptest/d' tests/CMakeLists.txt &&\
	WBD && BD && cmake -D CMAKE_INSTALL_PREFIX=/usr $SDIR/$SRC &&
	MO && MI
;;
"atk") $mur ;;
"libjpeg-turbo")

	O && WBD && BD && cmake -D CMAKE_INSTALL_PREFIX=/usr        \
      -D CMAKE_BUILD_TYPE=RELEASE         \
      -D ENABLE_STATIC=FALSE              \
      -D CMAKE_INSTALL_DEFAULT_LIBDIR=lib \
      -D CMAKE_SKIP_INSTALL_RPATH=ON      \
      $SDIR/$SRC && MO && MI && DI
;;
"at-spi2-core") $mur ;;
"at-spi2-atk")	$mur ;;
"fribidi") $mur ;;
"geany") $ru ;;
"pango") $mur --wrap-mode=nofallback ;;
"cairo") $mur ;;

"librsvg") export CARGO_HTTP_CAINFO=/etc/ssl/certs/bundle.crt && $mur --buildtype=release ;;
"libsoup") $mur  -D vapi=enabled     \
            -D gssapi=disabled  \
            -D sysprof=disabled ;;

"glib-networking") $mur  -D libproxy=disabled ;;
"gsettings-desktop-schemas") $mur ;;
"libtasn1") $ru ;;
"gnutls") $ru ac_cv_have_decl_alarm=no gl_cv_func_sleep_works=yes \
 --with-included-unistring  \
 --disable-tests \
 --with-default-trust-store-pkcs11="pkcs11:" ;;


"spacefm")
	O && BD && CFLAGS="-fcommon -Wno-implicit-function-declaration -Wno-incompatible-pointer-types" $cx --disable-video-thumbnails && make -s && make install && \
	gtk-update-icon-cache -q -t -f /usr/share/icons/Faenza &&
	gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor
;;


"wezterm")
	BUILD_OPTS=" --release "
	O && BD && PATH=$PATH:/opt/rustc-1.82.0/bin &&\
	cargo update -p time &&\
	
	cargo build --release --no-default-features --features vendored-fonts \
		-p wezterm-gui -p wezterm  -p wezterm-mux-server -p strip-ansi-escapes &&\
		
		install -Dsm755 target/release/wezterm -t $ODIR/usr/bin &&\
install -Dsm755 target/release/wezterm-mux-server -t $ODIR/usr/bin &&\
install -Dsm755 target/release/wezterm-gui -t $ODIR/usr/bin &&\
install -Dsm755 target/release/strip-ansi-escapes -t $ODIR/usr/bin
	


;;
"poppler")
CMN  -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D TESTDATADIR=$PWD/testfiles \
      -D ENABLE_QT5=OFF             \
      -D ENABLE_UNSTABLE_API_ABI_HEADERS=ON \
;;
"double-conversion")
CMN  -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
	-D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -D BUILD_SHARED_LIBS=ON             \
      -D BUILD_TESTING=ON                 \

;;

"inkscape")
O && WBD && BD &&
cmake $SDIR/$SRC
make
make install
;;

"libaom")
	CMN  -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D BUILD_SHARED_LIBS=1       \
      -D ENABLE_DOCS=no
;;

"libass") $rud ;;
"fdk-aac") $rud ;;
"lame") $rud --enable-mp3rtp ;;
"libvorbis") $rud ;;
"libogg") $rud ;;
"libvpx") WBD && $rud --enable-shared ;;
"x264") $rud --enable-shared --disable-cli ;;
"x265")
O && WBD && BD &&
cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D GIT_ARCHETYPE=1           \
      -W no-dev $SDIR/$SRC/source
make &&\
make install &&\
rm -vf /usr/lib/libx265.a 

;;  
"opus")	$mur ;;

"fbdev") $ru ;;


"ffmpeg")
	$rud --enable-gpl         \
            --enable-version3    \
            --enable-nonfree     \
            --enable-shared      \
            --disable-debug      \
            --enable-libaom      \
            --enable-libass      \
            --enable-libfdk-aac  \
            --enable-libfreetype \
            --enable-libmp3lame  \
            --enable-libopus     \
            --enable-libvorbis   \
            --enable-libvpx      \
            --enable-libx264     \
            --enable-libx265     \
            --enable-openssl     \
            --enable-ffmpeg     \
            --ignore-tests=enhanced-flv-av1
;;
 


*) $rx ;;


esac
