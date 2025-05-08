#!/bin/sh
export DISPLAY=:0.0

/usr/bin/Xorg -nolisten tcp &
export XPID=$!

echo "XPID=$XPID DISPLAY=$DISPLAY wait xdpyinfo"

MAX=60 
CT=0
while ! xdpyinfo >/dev/null 2>&1; do
    sleep 0.50s
    CT=$(( CT + 1 ))
    if [ "$CT" -ge "$MAX" ]; then
        echo "FATAL: $0: Gave up waiting for X server XPID=$XPID"
        exit 11
    fi
    echo -e "$CT\r"
done

(
	#initialize whatever i'm missing 
	sleep 1
	setxkbmap es
	[ -f "~/.club/windows" ] && . ~/.club/windows 
	
) & jwm > /var/log/jwm.log 2>&1

echo "Ending xserver ..."
kill $XPID




