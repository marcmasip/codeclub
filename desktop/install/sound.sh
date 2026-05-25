#!/usr/bin/env bash

. conf.sh
. $ldir/script/show.sh
. macro.sh




r="oa --prefix=/usr" 
cx="cf --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static"
rx="$r --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static"
rxs="$r --prefix=/usr --sysconfdir=/etc --localstatedir=/var "
ru="$r --prefix=/usr"
rud="$ru --disable-static"
mu="mes --prefix=/usr"
mu32="mes32 --prefix=/usr"
mur="$mu --prefix=/usr"





# SOUND?
ins_alsa_lib(){
	at "https://www.alsa-project.org/files/pub/lib/alsa-lib-1.2.15.3.tar.bz2" && $r && r32 &&\
	tar -C /usr/share/alsa --strip-components=1 -xf ../alsa-ucm-conf-1.2.15.3.tar.bz2
	
	return $?	
}
ins_alsa_conf(){
	at "https://www.alsa-project.org/files/pub/lib/alsa-ucm-conf-1.2.15.3.tar.bz2" && o && bd &&\
	ls
	return $?
	
}
ins_alsa_utils(){
	at "https://www.alsa-project.org/files/pub/utils/alsa-utils-1.2.15.2.tar.bz2" && $r --disable-alsaconf \
            --disable-bat      \
            --disable-xmlto    \
            --with-curses=ncursesw 
    return $?
}

ins_alsa_tools(){
	at "https://www.alsa-project.org/files/pub/tools/alsa-tools-1.2.15.tar.bz2" && $r
	return $?
}

ins_flac(){
	 at https://github.com/xiph/flac/releases/download/1.5.0/flac-1.5.0.tar.xz && $rx --disable-thorough-tests
	 return $?
 }
	 

ins_libsndfile(){
	at https://github.com/libsndfile/libsndfile/releases/download/1.2.2/libsndfile-1.2.2.tar.xz && o &&\
	sed '/typedef enum/,/bool ;/d' -i src/ALAC/alac_{en,de}coder.c &&\
	ca --prefix=/usr && r32
	return $?
	
}


ins_pulseaudio(){
	at https://www.freedesktop.org/software/pulseaudio/releases/pulseaudio-17.0.tar.xz &&
	$mur  -D database=gdbm    \
            -D doxygen=false    \
            -D bluez5=disabled  \
            -D tests=false    
    return $?
}
ins_pulseaudio32(){
	at https://www.freedesktop.org/software/pulseaudio/releases/pulseaudio-17.0.tar.xz && export at_name=pulseaaudio src=pulseaudio item=pulseaudio && $mu32
	return $?
}




run_item
