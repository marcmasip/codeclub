#!/usr/bin/env bash

. conf.sh
. $ldir/script/show.sh
. macro.sh




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
             --enable-slirp           
}


ins_picom(){
	
	at  "https://github.com/yshui/picom/archive/refs/tags/v13.tar.gz" 13 && $mur 
	return $?
}

ins_xmms(){
	at "http://www.xmms.org/files/1.2.x/xmms-1.2.10.tar.bz2" "13-rc1" &&\
	$rx
	return $?
}


run_item
