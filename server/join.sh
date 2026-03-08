#!/usr/bin/env bash
set -e

# Cargar configuración
. params.sh
. $ldir/util/global.sh

cd "$odir" || exit 1

case "${1:-}" in

quit)

sudo mountpoint -q "$odir/dev/shm" && sudo umount "$odir/dev/shm" 2>/dev/null || true
sudo umount "$odir/dev/pts" 2>/dev/null || true
sudo umount "$odir/sys" 2>/dev/null || true
sudo umount "$odir/proc" 2>/dev/null || true
sudo umount "$odir/run" 2>/dev/null || true
sudo umount "$odir/dev" 2>/dev/null || true
sudo umount "$odir/tmp" 2>/dev/null || true
sudo umount root/club/util 2>/dev/null || true
sudo umount root/club/library 2>/dev/null || true
sudo umount root/club/64 2>/dev/null || true

say "join: quit"
;;

*)
# Crear directorios necesarios
mkdir -pv proc tmp sys run dev root/club/{64,util,library}
sudo mkdir -p var/club/log tmp/club/{build,src}

# Montar sistemas de archivos virtuales
say "join: montando sistemas de archivos..."

# /dev
sudo mount --bind /dev dev/
sudo mount -vt devpts devpts -o gid=5,mode=0620 "$odir/dev/pts"

# Crear nodos de dispositivo esenciales
sudo mknod -m 600 "$odir/dev/console" c 5 1 2>/dev/null || true
sudo mknod -m 666 "$odir/dev/null" c 1 3 2>/dev/null || true
sudo mknod -m 666 "$odir/dev/tty" c 5 0 2>/dev/null || true
sudo mknod -m 666 "$odir/dev/ptmx" c 5 2 2>/dev/null || true

# proc, sys, run, tmp
sudo mount -vt proc proc "$odir/proc"
sudo mount -vt sysfs sysfs "$odir/sys"
sudo mount -vt tmpfs tmpfs "$odir/run"
sudo mount -vt tmpfs tmpfs "$odir/tmp"

# Montar directorios del proyecto
sudo mount --bind "$cdir/library" root/club/library
sudo mount --bind "$cdir/util" root/club/util
sudo mount --bind "$cdir/64" root/club/64

# Entrar al entorno chroot
say "join: entrando en nuevo entorno"
sudo chroot "$odir" /usr/bin/env -i /bin/busybox sh

# Limpiar al salir
say "join: desmontando sistemas de archivos..."
cd "$odir"

sudo mountpoint -q "$odir/dev/shm" && sudo umount "$odir/dev/shm" 2>/dev/null || true
sudo umount "$odir/dev/pts" 2>/dev/null || true
sudo umount "$odir/sys" 2>/dev/null || true
sudo umount "$odir/proc" 2>/dev/null || true
sudo umount "$odir/run" 2>/dev/null || true
sudo umount "$odir/dev" 2>/dev/null || true
sudo umount "$odir/tmp" 2>/dev/null || true
sudo umount root/club/util 2>/dev/null || true
sudo umount root/club/library 2>/dev/null || true
sudo umount root/club/64 2>/dev/null || true

say "join: fin"

;;

esac
