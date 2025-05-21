# Base components setup

CDIR=$(realpath ../)
LDIR=/root/club/library
TDIR=/tmp/club
GDIR=/tmp/club/log
RDIR=/var/club/log
VDIR=/var/club/log
OTAR=x86_64-club-linux-gnu
OTAR32=i686-club-linux-gnu
ODIR=/
GUIDE="64"
. ../util/guides.sh

export LC_ALL=POSIX \
CONFIG_SITE=$ODIR/usr/share/config.site \
JOBS=6 \


if [ "$1" == "info" ]; then 
	SAY "ODIR=$ODIR"
	SAY "OTAR=$OTAR OTAR32=$OTAR32"
	SAY "VDIR=$VDIR"
	SAY "GDIR=$GDIR"
	SAY "PATH=$PATH"
	
	cd $VDIR
	
	st=""
	for file in *.res; do
	  if [ "$(head -n 1 "$file")" != "0" ]; then
		st="$st 🧨 ${BOLD}$file${RESET}			" 
	  else
		st="$st ✅ ${BOLD}$file${RESET}				" 
	  fi
	done
	echo "$st"
	
	local sta=""
	for key in "${!PKG_MAP[@]}"; do
	 sta="$sta, 📜 $key				" 
	done
	echo "$sta"
	
	exit
fi


if [ "$2" == "all" ]; then

	if [ "$1" == "tools2" ]; then 
		R welcome
		R gettext
		R bison
		R perl
		R Python
		R texinfo
		R util-linux
		R util-linux32
	fi


	if [ "$1" == "base" ]; then

		R glibc #; R glibc-setup ; R glibc-32 
		R zlib  #; R zlib-32
		R bzip2 #; R bzip2-32
		R xz 	#; R xz-32
		R lz4 #; R lz4-3
		R zstd #; R zstd-32
		R file #; R file-32
		R readline #; R readline-32
		
		R m4 
		R lzip 
		R ed 
		R bc 
		R flex 
		R pkgconf 
		R binutils 
		R gmp 
		R mpfr 
		R mpc 
		R libxcrypt 
		R gcc 
		R ncurses 
		R sed 
		R autoconf 
		R automake 
		R gettext 
		R psmisc 
		
		R bison 
		R grep 
		R gperf 
		R bash 
		R libtool 
		R inetutils 
		R less 
		R perl 
		R libexpat 
		R openssl 
		R certs 
		R wget 
		R kmod 
		R libelf 
		R libffi 
		R Python 
		R flit-core 
		R wheel 
		R setuptools 
		R ninja 
		R meson 
		R coreutils 
		R diffutils 
		
		R gawk 
		R findutils 
		R git 
		R iproute2 
		R kbd 
		R libpipeline 
		R eudev 
		R libtirpc 
		R make 
		R patch 
		R tar 
		R texinfo 
		R wget 
		R util-linux 
		R e2fsprogs 
		R nasm 
		R which 
		R asciidoc 
		
		R check 
		R XML-Parser 
		R intltool 
		
		R htop 
		R gdbm 
		R shadow 
		R pciutils 
		R hwdata 
		R groff 
		R lsof 
		
		R zip 
		#R unzip 
		R pcre2
		
		R nsrp
		R nss

		R libarchive
		R sqlite
		R libpsl
		R curl 
		R libuv
		R cmake 
		
		R llvm
		R rustc
		R cargo-c
		
		R mtdev 
		R vim
		
		R libxml2
		
		R spa
		
		R alsa-lib
		R alsa-plugins
		R alsa-utils
		R flac
		R libsndfile
		R pulseaudio
		
		R graphite2
		R harfbuzz
		R fribidi

		R syslinux 
		
	fi
	
	
		

	if [ "$1" == "windows" ]; then

		
		R freetype 
		R fontconfig
		 
		R util-macros 
		R xorgproto 
		R xtrans
		R libXau
		R libXdmcp 
		R xcb-proto 
		R libxcb 
		
		R libX11 
		R libXext 
		R libFS 
		R libICE 
		R libSM 
		R libXScrnSaver 
		R libXt 
		R libXmu 
		R libXpm 

		R libXaw 
		R libXfixes
		R libXcomposite 
		R libXrender 
		R libXcursor 
		R libXdamage 
		R libfontenc 
		R libXfont2 
		R libXft 
		R libXi 
		R libXinerama 
		R libXrandr 
		R libXres 
		R libXtst 
		R libXv 
		R libXvMC 
		R libXxf86dga 
		R libXxf86vm 
		R libpciaccess 
		R libxkbfile 
		R libxshmfence 
		
			
			
		R glib
		R gobject-introspection
		R glib2
		
		R gdk-pixbuf
		R at-spi2-core
		R at-spi2-atk
		R pango
		
		R atk
		
		R MarkupSafe 
		R Mako 
		R pixman 
		R libxml2 
		R libpng 
		R cairo 
		R shared-mime-info
		R libjpeg-turbo

		R librsvg 

		#R libsecret

		R libdrm

		R libva 
		# R libclc &&
		R libvdpau 

		R pyyaml
		
		R wayland 
		R wayland-protocols 
		
		
		
		R libass
		R fdk-aac
		R lame
		R libogg
		R libvorbis
		R libaom
		R opus
		R libvpx
		R x264
		R x265
		R ffmpeg
		
		R glslang 
		R mesa 
		R libepoxy 
		
		R xcb-util 
		R xcb-util-image 
		R xcb-util-keysyms 
		R xcb-util-renderutil 
		R xcb-util-wm 
		R xcb-util-cursor 
		R libxcvt 
		R font-util 
		R xorg-server 
		
		R libevdev 
		R libinput 
		R xkeyboard-config 
		R libxkbcommon 
		R xbitmaps
		R xf86-input-evdev 
		R xf86-video-amdgpu 
		R xf86-video-fbdev
		
		
		# utils
		R iceauth 
		R mkfontscale 
		R sessreg 
		R setxkbmap 
		R smproxy 
		R x11perf 
		R xauth 
		R xcmsdb 
		R xcursorgen 
		R xdpyinfo 
		R xdriinfo 
		R xev 
		R xgamma 
		R xhost 
		R xinput 
		R xkbcomp 
		R xkbevd 
		R xkbutils 
		R xkill 
		R xlsatoms 
		R xlsclients 
		R xmessage 
		R xmodmap 
		R xpr 
		R xprop 
		R xrandr 
		R xrdb 
		R xrefresh 
		R xset 
		R xsetroot 
		R xvinfo 
		R xwd 
		R xwininfo 
		R xwud 
		R xclock 
		
		#R xdg-utils

		# libs
		R gtk3
		
		# apps
		
		
		R jwm 
		R spacefm
		R geany 
		
	fi
	
	DO_R
	
else

	GUIDE_ITEM
	
fi











