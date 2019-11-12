emulos#!/bin/sh
#
# disabling Dreamcast date/time Fix
#

# creates backup config
if [ -f "/opt/emulos/emulators/reicast/bin/reicast.bk" ];
then
   echo "already backed up"
else
   echo "backing up"
   cp /opt/emulos/emulators/reicast/bin/reicast /opt/emulos/emulators/reicast/bin/reicast.bk
fi

# disabling Dreamcast date/time fix
sudo cp /home/pi/EmulOS/scripts/reicast_default /opt/emulos/emulators/reicast/bin/reicast
echo "Emulador Reicast actualizado, reiniciando..."
echo

# rebooting
sudo reboot
