#!/usr/bin/env bash
echo "Checking to see if advance-mame 1.4 is installed if it is not I will install it. This will take a little while to run......."
sleep 5

if [ ! -d "/home/pi/EmulOS/roms/mame-advmame" ]; then
        echo "Advance-Mame not found. Installing version 1.4. This will take around 30min."
        sleep 10
        sudo /home/pi/EmulOS-Setup/emulos_pkgs.sh 101
fi

echo ""
echo ""
echo "Instalando los paquetes necesarios para la aplicación de configuración de la pistola."
sleep 3
sudo apt-get -y install apt-transport-https python-dev python-pygame python-setuptools
echo ""
echo ""
echo "Haciendo cambios de configuración de mame por adelantado para que tu Aimtrak sea detectada en el juego."
sleep 3
sed -i 's/device_mouse auto/device_mouse raw/g' /home/pi/.advance/advmame-1.4.rc
sed -i 's/device_raw_mousedev\[0\] auto/device_raw_mousedev[0] \/dev\/input\/mouse0/g' /home/pi/.advance/advmame-1.4.rc
sed -i 's/device_raw_mousedev\[1\] auto/device_raw_mousedev[1] \/dev\/input\/mouse1/g' /home/pi/.advance/advmame-1.4.rc
sed -i 's/device_raw_mousedev\[2\] auto/device_raw_mousedev[2] \/dev\/input\/mouse2/g' /home/pi/.advance/advmame-1.4.rc
sed -i 's/device_raw_mousedev\[3\] auto/device_raw_mousedev[3] \/dev\/input\/mouse3/g' /home/pi/.advance/advmame-1.4.rc
sed -i 's/device_raw_mousetype\[0\] pnp/device_raw_mousetype[0] ps2/g' /home/pi/.advance/advmame-1.4.rc
sed -i 's/device_raw_mousetype\[1\] pnp/device_raw_mousetype[1] ps2/g' /home/pi/.advance/advmame-1.4.rc
sed -i 's/device_raw_mousetype\[2\] pnp/device_raw_mousetype[2] ps2/g' /home/pi/.advance/advmame-1.4.rc
sed -i 's/device_raw_mousetype\[3\] pnp/device_raw_mousetype[3] ps2/g' /home/pi/.advance/advmame-1.4.rc
echo ""
echo ""
echo "Comprobando el archivo cheats.dat. Instalaré y habilitaré trucos para Advance-Mame si son necesarios."
sleep 5
if [ ! -f "/home/pi/.advance/cheat.dat" ]; then
	echo ""
    echo ""
	echo "Los trucos no están instalados. Instalándolos y habilitándolos por ti."
	sleep 5
cd /home/pi/.advance
wget https://raw.githubusercontent.com/libretro/mame2003-libretro/master/metadata/cheat.dat
sed -i 's/misc_cheat no/misc_cheat yes/g' /home/pi/.advance/advmame-1.4.rc
fi
echo ""
echo ""
echo "Descargando aplicación de configuración para la pistola. Esto aparecerá en su menú de EmulOS después de la instalación. Tendrás que calibrar la pistola antes de jugar."
sleep 8
cd
git clone https://github.com/gunpadawan/gunconf.git
cd gunconf
sudo cp utils/aimtrak.rules /etc/udev/rules.d/99-aimtrak.rules
sudo udevadm control --reload-rules
sudo python setup.py install
cp ./utils/gunconf.sh ~/EmulOS/emulosmenu/
sudo rm -r ./gunconf
echo ""
echo ""
echo "Comprobando si tienes algún tirador. Si no consigue enganchar algunos para que comience"
cd /home/pi/EmulOS/roms/mame-advmame/
if [ ! -f "/home/pi/EmulOS/roms/mame-advmame/alien3.zip" ]; then
        wget http://eazyhax.com/pitime/shooter/alien3.zip
fi
if [[ ! -f "/home/pi/EmulOS/roms/mame-advmame/le2.zip" ]]; then
        wget http://eazyhax.com/pitime/shooter/le2.zip
fi
if [[ ! -f "/home/pi/EmulOS/roms/mame-advmame/duckhunt.zip" ]]; then
        wget http://eazyhax.com/pitime/shooter/duckhunt.zip
fi
echo ""
echo ""
echo "Todo listo. Disfruten y recuerden .... Un disparo una muerte! Tu Pi ahora se reiniciará"
sleep 10
sudo reboot
