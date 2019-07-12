#!/bin/sh

esdir="$(dirname $0)"
while true; do
    rm -f /tmp/es-restart /tmp/es-sysrestart /tmp/es-shutdown
    "$esdir/emulationstation" "$@"
    ret=$?
    [ -f /tmp/es-restart ] && continue
    if [ -f /tmp/es-sysrestart ]; then
        rm -f /tmp/es-sysrestart
		sudo omxplayer -b EmulOS/shutdown/Reiniciando.mp4
        sudo reboot
        break
    fi
    if [ -f /tmp/es-shutdown ]; then
        rm -f /tmp/es-shutdown
		sudo omxplayer -b EmulOS/shutdown/Apagando.mp4
        sudo poweroff
        break
    fi
    break
done
exit $ret
