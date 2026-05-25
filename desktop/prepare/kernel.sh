#!/usr/bin/env bash

. params.sh
. $ldir/script/show.sh

kn="linux-club-$2"

case "${1:-}" in

conf) say "Configurar $kn en BDIR ?"
	mkdir -p "$bdir/$kn"
	cd "$bdir/$kn"
	if [[ ! -e "$bdir/$kn/.config" ]]; then
		cp "$ldir/etc/.config-$kn" "$bdir/$kn/.config"
	fi
	make -C "$ldir/develop/linux-7.1-rc3" O="$bdir/$kn" menuconfig
	make -C "$ldir/develop/linux-7.1-rc3" O="$bdir/$kn" prepare
;;

save) say "Guardar $kn en BDIR ?"

	if [[ -e "$bdir/$kn/.config" ]]; then
		cp "$bdir/$kn/.config" "$ldir/etc/.config-$kn" 
	fi

;;

make) say "Compilando $kn en BDIR"
	mkdir -p "$bdir/$kn"
	cd "$bdir/$kn"
	#cp "$ldir/conf/.config-$kn" "$bdir/$kn/.config"
	make -j6 -C "$ldir/develop/linux-7.1-rc3" O="$bdir/$kn" bzImage
;;
	
	
modules) say "Modules $kn en BDIR"
	mkdir -p "$bdir/$kn"
	cd "$bdir/$kn"
	#cp "$ldir/conf/.config-$kn" "$bdir/$kn/.config"
	make -j6 -C "$ldir/develop/linux-7.1-rc3" O="$bdir/$kn" modules &&\
	mkdir -p "$bdir/$kn" &&\
        DEST="$bdir/$kn/dist" &&\
        mkdir -p "$DEST" &&\
	make -C "$ldir/develop/linux-7.1-rc3" O="$bdir/$kn" \
             INSTALL_MOD_PATH="$DEST" modules_install
;;
esac
