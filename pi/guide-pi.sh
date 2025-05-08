# Base components setup

PWD=$(pwd)
CDIR=$(realpath $PWD/.. )
TDIR=$CDIR/tmp
GDIR=$TDIR/log
RDIR=$TDIR/log
VDIR=$GDIR

PI_XDIR=/opt/cross/pi
PI_STDIR=$CDIR/pi/staging
PI_STDIR_FS=$CDIR/pi/rootfs
ODIR=$PI_XDIR/sysroot
OTAR=arm-club-linux-gnueabihf

GUIDE=pi
. ./guides.sh


if [ "$1" == "test" ]; then


	qemu-system-arm \
	  -M raspi2b   \
	  -kernel $PI_STDIR/kernel-club-pi.zimage   \
	  -initrd $PI_STDIR/initramfs.gz   \
	  -dtb $PI_STDIR/bcm2836-rpi-2-b.dtb \
	  -append "console=ttyAMA0 init=/init earlyprintk=serial" \
	  -nographic
	exit
fi

if [ "$1" == "sd-fs" ]; then
	
	
	DISK="$3"
	mkdir $BDIR/sd; 
	mount /dev/$DISK $BDIR/sd &&\
	cp $PI_STDIR/initramfs.gz $BDIR/sh &&\
	umount $BDIR/sd

	exit;
fi


copy_deps() {
    local bin="$1"
    local sysroot="$2"
    local final="$3"
    local seen=()

    _copy_recursive() {
        local file="$1"
	
        # Evitar repetir
        for s in "${seen[@]}"; do
            [[ "$s" == "$file" ]] && return
        done
        seen+=("$file")

        # Ruta absoluta del binario en sysroot
        local src_path="$sysroot$file"
        local dest_path="$final$file"

        # Copiar si no existe ya
        if [ ! -f "$dest_path" ]; then
            mkdir -p "$(dirname "$dest_path")"
            SAY "Copiando $file"
            cp -av "$src_path" "$dest_path" 2>/dev/null || echo "No encontrado: $src_path"
        else
        	SAY "Existe $dest_path"
        fi

        # Analizar dependencias
        local deps
        deps=$(readelf -d "$src_path" 2>/dev/null | grep NEEDED | awk -F'[][]' '{print $2}')

        for dep in $deps; do
            local found_dep
            SAY "DEP=$dep"
            found_dep=$(find "$sysroot" -name "$dep" | head -n 1)
            if [ -n "$found_dep" ]; then
                # Obtener ruta relativa dentro del sysroot
                local rel="${found_dep#$sysroot}"
                _copy_recursive "$rel"
            else
                echo "⚠️  No se encontró dependencia: $dep"
            fi
        done
    }

    # Obtener ruta relativa dentro de sysroot
    local rel="${bin#$sysroot}"
    _copy_recursive "$rel"
}

if [ "$1" == "copy" ]; then
	copy_deps "$PI_XDIR/sysroot/$2" "$PI_XDIR/sysroot" "$PI_STDIR_FS"
	exit

fi

GUIDE_ITEM


