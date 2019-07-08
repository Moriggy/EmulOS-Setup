#!/bin/sh
#
# Run this script to overclock the Raspberry Pi
# After applying the settings, it reboots the system.
#
# To return to the normal state, run normal.sh.
#

# creates backup config
if [ -f "./config.txt.bak" ];
then
   echo "already backed up"
else
   echo "backing up"
   cp /boot/config.txt ./config.txt.bak
fi

# applies overclocked settings
sudo cp /home/pi/EmulOS/scripts/config_overclock1550rpi3bplus.txt /boot/config.txt
echo "Configuración de Overclock añadida, reiniciando..."
echo
echo "Para quitar el Overclock, ejecuta sin overclock"
echo

# rebooting
sudo reboot
