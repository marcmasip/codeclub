#!/usr/bin/env bash

. params.sh
. $ldir/script/show.sh

saydir $kimg
saydir $oimg

# Parámetros: 
# $1 = modo (image, bridge_setup, usb)
# $2 = tipo de red para el modo image (user o bridge)

case "${1:-}" in

    image)
        # Por defecto usamos 'user', pero si $2 es 'bridge', cambiamos la config
NET_TYPE="${2:-user}"
    
    if [ "$NET_TYPE" = "bridge" ]; then
        # IMPORTANTE: Usamos virtio-net-pci y forzamos el nombre de la interfaz
        NET_OPTS="-netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:56"
        SUDO="sudo"
    else
        NET_OPTS="-nic user,model=virtio-net-pci"
        SUDO=""
    fi

    $SUDO qemu-system-x86_64 \
      -m 2048 \
      -kernel "$kimg" \
      -append "root=/dev/vda rw debug=true ipv6.disable=1 net.ifnames=0" \
      -blockdev driver=file,filename="$oimg",node-name=sys \
      -device virtio-blk-pci,drive=sys,bootindex=1 \
      $NET_OPTS
    ;;

    setup_bridge)
        # Este bloque prepara el host (solo hay que hacerlo una vez)
        echo "Configurando bridge br0 y tap0..."
        sudo brctl addbr br0 && \
        sudo ip tuntap add dev tap0 mode tap user marc && \
        sudo ip link set dev tap0 up && \
        sudo brctl addif br0 tap0 && \
        sudo killall dhcpcd && \
        sudo ip addr flush dev eth0 && \
        sudo brctl addif br0 eth0 && \
        sudo dhcpcd br0
    ;;

    usb)
        # (Tu código de USB se mantiene igual)
        sudo umount /dev/sdc* 2>/dev/null
        sudo qemu-system-x86_64 \
            -m 1G \
            -device virtio-vga,xres=1920,yres=1080 \
            -bios /home/marc/Descargas/OVMF.fd \
            -nic user,model=e1000,hostfwd=tcp::2222-:2020 \
            -blockdev driver=host_device,filename=/dev/sdc,node-name=usbdat,cache.direct=on,cache.no-flush=off \
            -device virtio-blk-pci,drive=usbdat,bootindex=1
    ;;

    *)
        echo "Uso: $0 {image [user|bridge]|setup_bridge|usb}"
        exit 1
    ;;
esac