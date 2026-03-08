#!/usr/bin/env bash

. params.sh
. $ldir/script/show.sh

saydir $kimg
saydir $oimg

case "${1:-}" in

	images)
	
	


qemu-system-x86_64 \
  -m 2048 \
  -kernel "$kimg" \
  -vga virtio \
  -append "root=/dev/vda rw debug=true  ipv6.disable=1" \
  -blockdev driver=file,filename="$oimg",node-name=sys \
  -device virtio-blk-pci,drive=sys,bootindex=1 \
  -blockdev driver=file,filename="$dimg",node-name=zfsimg \
  -device virtio-blk-pci,drive=zfsimg,bootindex=2 \
  -blockdev driver=host_device,filename=/dev/sdb,node-name=zfsdat,cache.direct=on,cache.no-flush=off \
  -device virtio-blk-pci,drive=zfsdat,bootindex=3 \
  -nic tap,ifname=tap0,model=e1000,script=no,downscript=no
  
;;


bridge)

	brctl addbr br0 &&\
	ip tuntap add dev tap0 mode tap user marc &&\
	ip link set dev tap0 up &&\
	brctl addif br0 tap0 &&\
	killall dhcpcd &&\
	ip addr flush dev eth0 &&\
	brctl addif br0 eth0 &&\
	dhcpcd br0
;;


diskdev)

umount /dev/sdb* 
sudo qemu-system-x86_64 \
    -kernel "$kimg" \
    -vga std \
	-append "root=/dev/vda rw debug=true  ipv6.disable=1" \
    -nic tap,ifname=tap0,model=e1000,script=no,downscript=no \
    -blockdev driver=file,filename="$oimg",node-name=sys \
	-device virtio-blk-pci,drive=sys,bootindex=1 \
    -blockdev driver=host_device,filename=/dev/sdb,node-name=diskdev,cache.direct=on,cache.no-flush=off \
	-device virtio-blk-pci,drive=diskdev
  
;;

usb)

umount /dev/sdc* 
sudo qemu-system-x86_64 \
    -m 1G \
    -device virtio-vga,xres=1920,yres=1080 \
    -bios /home/marc/Descargas/OVMF.fd \
    -nic user,model=e1000,hostfwd=tcp::2222-:2020 \
    -blockdev driver=host_device,filename=/dev/sdc,node-name=usbdat,cache.direct=on,cache.no-flush=off \
	-device virtio-blk-pci,drive=usbdat,bootindex=1
  
;;

esac

