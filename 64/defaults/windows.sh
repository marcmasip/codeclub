#!/bin/sh
export DISPLAY=:0.0

/usr/bin/Xorg -nolisten tcp &
export XPID=$!
echo "XPID=$XPID DISPLAY=$DISPLAY testing xdpyinfo ... "

MAX=60 # About 60 seconds
CT=0
while ! xdpyinfo >/dev/null 2>&1; do
    sleep 0.50s
    CT=$(( CT + 1 ))
    if [ "$CT" -ge "$MAX" ]; then
        LOG "FATAL: $0: Gave up waiting for X server $DISPLAY"
        exit 11
    fi
done


if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

pulseaudio --start

jwm &
export WPID=$!

[ -f "/home/person/.windows" ] && . /home/person/.windows
[ -f "/home/$USER/.windows" ] && . /home/$USER/.windows

echo "Waiting WM"
wait $WPID

echo "Ending xserver ..."
kill $XPID




