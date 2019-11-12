#!/bin/sh
#
# Run this script to cancel the overclocking. This will return the
# raspberry pi to the standard settings and reboot the system.
#

# applying standard, factory settings
sudo cp /home/pi/EmulOS-Setup/scriptmodules/extras/scripts/config_std.txt /boot/config.txt
echo "Aplicados valores por defecto, reiniciando..."
echo

# rebooting
sudo reboot
