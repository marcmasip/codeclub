# Base components setup
BUILDU=marc
ODIR=$(realpath ../64/sysroot)
GUIDE="64"
. ../util/guides.sh
OIMG=$(realpath ../64/sysroot.img)
KIMG=$(realpath ../64/kernel-work)
VDIR=$GDIR

set +h
umask 022

PATH=$ODIR/tools/bin:$PATH
OTAR=x86_64-club-linux-gnu
OTAR32=i686-club-linux-gnu

export ODIR LC_ALL OTAR32 PATH LC_ALL=POSIX \
CONFIG_SITE=$ODIR/usr/share/config.site \
JOBS=8 \
SRC="$ITEM" 


# Shortcuts


# Item plans

[ "$1" == "obtain" ] && O $2 &&	exit



if [ "$1" == "info" ]; then 

	SAY "ODIR=$ODIR"
	SAY "OTAR=$OTAR"
	SAY "OTAR32=$OTAR32"
	SAY "PATH=$PATH"
	exit
fi

if [ "$1" == "tmp" ]; then

	sudo mount -vt tmpfs tmpfs $CDIR/tmp &&\
	sudo chown $BUILDU $CDIR/tmp &&\
	mkdir -v $CDIR/tmp/{build,src,log} 
	SAY "TEMPORALES"
	exit;
fi


if [ "$1" == "test" ]; then

	qemu-system-x86_64 \
		  -m 1024 \
		  -kernel $KIMG \
		  -append "root=/dev/sda rw debug=true" \
		   -hda $OIMG   
		  

fi 


if [ "$1" == "export-work" ]; then
	DEV="/dev/sdb"
	PART="${DEV}1"
	DISKIMG="$CDIR/64/sysroot.img"
	MBR="$CDIR/64/mbr.bin"
	
	mkdir  $BDIR/export-work ; cd $BDIR/export-work &&\
SAY "GUARDANDO TABLAS"	
	sudo dd if="$DEV" bs=1 count=66 skip=446 of=ptable.bin &&\
SAY "COPIANDO MBR"
	# Escribir solo los primeros 446 bytes del MBR personalizado
	sudo  dd if="$MBR" bs=1 count=446 of="$DEV" conv=notrunc &&\
SAY "COPIANDO TABLAS"
	# Reescribir tabla de particiones
	sudo  dd if=ptable.bin of="$DEV" bs=1 seek=446 conv=notrunc &&\
	SAY "COPIANDO PAQUETON"
	sudo  dd if="$DISKIMG" of="$PART" bs=4M status=progress conv=fsync &&\
	

	exit
fi




if [ "$1" == "kernel-work-config" ]; then

	mkdir $BDIR/linux64 ; cd $BDIR/linux64 &&\
	cp $LDIR/conf/.config-linux-club-work $BDIR/linux64/.config && \
	make -C $LDIR/linux-club O=$BDIR/linux64 menuconfig
	exit
fi




JOIN(){
	cd $ODIR
	mkdir -pv proc tmp sys run dev root/club/util root/club/library
	sudo mount --bind /dev dev/
	sudo mount -vt devpts devpts -o gid=5,mode=0620 $ODIR/dev/pts
	sudo mount -vt proc proc proc
	sudo mount -vt sysfs sysfs sys
	sudo mount -vt tmpfs tmpfs run
	sudo mount -vt tmpfs tmpfs tmp
	
	sudo mkdir -p tmp/club/build
	sudo mkdir -p tmp/club/src
	sudo mkdir -p var/club/log

	sudo mount --bind $CDIR/util root/club/util
	sudo mount --bind $CDIR/library root/club/library

	SAY "JOIN: Entrando en nuevo entorno"
	
	sudo /usr/bin/chroot "$ODIR" /usr/bin/env -i   \
		HOME=/root                  \
		TERM="$TERM"                \
		PS1='(club guides chroot) \u:\w\$ ' \
		PATH=/usr/bin:/usr/sbin:/bin     \
		MAKEFLAGS="-j4"      \
		TESTSUITEFLAGS="-j4" \
		/usr/bin/bash --login -c "cd /root/club ; $@"
	
	cd $ODIR
	sudo mountpoint -q $ODIR/dev/shm && umount $ODIR/dev/shm
	sudo umount $ODIR/dev/pts
	sudo umount $ODIR/{sys,proc,run,dev}

	sudo umount -R tmp root/club/library root/club/util
		
	SAY "JOIN: FIN"
	
}
if [ "$1" == "tools2" ]; then 
	JOIN " cd /root/club/util &&  ./guide-64.sh tools2 $2 "
	SAY "FIN"
	exit
fi

if [ "$1" == "join" ]; then 
	JOIN bash
	exit
fi


if [ "$2" == "all" ]; then

	R binutils
	R gcc1
	R kernel-headers
	R glibc
	R glibc32
	R libstdcpp
	R m4
	R ncurses
	R bash
	R coreutils
	R diffutils
	R file
	R findutils
	R gawk
	R grep
	R gzip
	R make
	R patch
	R sed
	R tar
	R xz
	R zstd
	R zlib
	R binutils2
	R gcc2	
	
	DO_R

else

	GUIDE_ITEM

fi

