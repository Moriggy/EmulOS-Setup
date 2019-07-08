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
   echo "Back up creado"
else
   echo "Creando back up"
   cp /boot/config.txt ./config.txt.bak
fi

# applies overclocked settings
sudo cp /home/pi/EmulOS/scripts/config_overclock1300rpi3.txt /boot/config.txt
echo "Configuración de overclock añadida, reiniciando..."
echo
echo "Para quitar el Overclock, ejecuta sin overclock"
echo

# rebooting
sudo reboot
