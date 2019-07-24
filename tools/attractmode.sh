#!/usr/bin/env bash

# ESTE FICHERO FORMA PARTE DEL PROYECTO MASOS CREADO POR MasOS TEAM 2018/2019.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/DOCK-PI3/MasOS-Setup/master/LICENSE.md
# Actualizado el 7-7-2019 para EmulOS.

rp_module_id="attractmode"
rp_module_desc="Attract Mode emulator frontend para raspberry pi 3b y b+ con compilacion de mmal incluida"
rp_module_licence="GPL3 https://raw.githubusercontent.com/mickelson/attract/master/License.txt"
rp_module_section="exp"

function main_menu() {
    local choice
    while true; do
        choice=$(dialog --backtitle "$BACKTITLE" --title " MAIN MENU " \
            --ok-label OK --cancel-label Exit \
            --menu "Quieres instalar Attract y no sabes? ...Hoy es tu dia de suerte!" 25 75 20 \
            1 "Instalar/Actualizar Attract Mode con mmal" \
			2 "Configuracion para Attract Mode en EmulOS" \
			2>&1 > /dev/tty)

        case "$choice" in
            1) emulos_attractinstall  ;;
			2) config_attract  ;;
			*)  break ;;
        esac
    done
}


#########################################################################
# Funcion Reparar permisos en MasOS PC ;-) #
function emulos_attractinstall() {

# Cierra ES para una mejor y mas rapida compilacion de attract y ffmpeg......
sudo killall emulationstation
sudo killall emulationstation-dev

# ACTUALIZAR LISTA DE PAQUETES
sudo apt-get update

# Crear entorno para compilar
cd /home/pi && mkdir develop

# Instalar las dependencias para "sfml-pi" y Attract-Mode
sudo apt-get install -y cmake libflac-dev libogg-dev libvorbis-dev libopenal-dev libfreetype6-dev libudev-dev libjpeg-dev libudev-dev libfontconfig1-dev

# Descargar y compilar sfml-pi
cd /home/pi/develop
git clone --depth 1 https://github.com/mickelson/sfml-pi sfml-pi
mkdir sfml-pi/build; cd sfml-pi/build
cmake .. -DSFML_RPI=1 -DEGL_INCLUDE_DIR=/opt/vc/include -DEGL_LIBRARY=/opt/vc/lib/libbrcmEGL.so -DGLES_INCLUDE_DIR=/opt/vc/include -DGLES_LIBRARY=/opt/vc/lib/libbrcmGLESv2.so
sudo make -j4 install
sudo ldconfig

# Compilar FFmpeg con soporte mmal (decodificacion de video acelerada por hardware)
cd /home/pi/develop
git clone --depth 1 git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
./configure --enable-mmal --disable-debug --enable-shared
make -j4
sudo make -j4 install
sudo ldconfig

# Descargar y compilar Attract-Mode
cd /home/pi/develop
git clone --depth 1 https://github.com/mickelson/attract attract
cd attract
make -j4 USE_GLES=1
sudo make -j4 install USE_GLES=1
sudo rm -r -f /home/pi/develop

# CONFIG INI PARA Attract-Mode
sudo chown -R pi:pi /home/pi/EmulOS/emulosmenu/
sudo cp /opt/emulos/configs/all/autostart.sh /opt/emulos/configs/all/autostart_backup.sh
cd
   cat > /home/pi/EmulOS/emulosmenu/Switch\ To\ Attract\ Mode.sh <<_EOF_
#!/usr/bin/env bash
echo ""
echo "Cambiando el arranque a Attract Mode y reiniciando..."
echo ""
sleep 5
cp /opt/emulos/configs/all/AM-Start.sh /opt/emulos/configs/all/autostart.sh
sudo reboot
_EOF_
cd
   sudo cat > /opt/emulos/configs/all/AM-Start.sh <<_EOF_
#!/usr/bin/env bash
attract
_EOF_
sudo chmod -R +x /home/pi/EmulOS/emulosmenu/Switch\ To\ Attract\ Mode.sh
sudo chmod -R +x /opt/emulos/configs/all/AM-Start.sh
sudo chown -R pi:pi /opt/emulos/configs/all/AM-Start.sh
sudo chown -R root:root /home/pi/EmulOS/emulosmenu/
cd && mkdir .attract
dialog --infobox " Se ha creado un script en el menu de ES para cambiar a attract mode, una vez que inicie attract seleccione su idioma,\nya puede usar atrractmode. " 350 350 ; sleep 10
dialog --infobox " Attract se instaló de forma correcta y con mmal. Ahora si quiere, despues de seguir las indicaciones anteriores, puedes ejecutar de nuevo el script e instalar la configuracion para attrac mode. \n\nNOTA IMPORTANTE: Antes de instalar la configuracion para attract tiene que iniciar attractmode una vez como minimo ,luego cierre attract ejecute emulationstation e inicie masos extras all para terminar de instalar la configuracion..., reiniciando en 20s" 350 350 ; sleep 20
sudo shutdown -r now
# ---------------------------- #
}

#########################################################################
# Funcion configurar attract en MasOS ;-) #
function config_attract() {
# Configurar Attract-Mode switchs ,menus ,emulators....
dialog --infobox "... Descargando ,descomprimiendo y copiando ficheros de configuracion para Attract y MasOS, SCRIPTS ,EMULATORS ,VIDEOS SISTEMAS ,THEMES ,ECT..." 370 370 ; sleep 5
cd /home/pi/ && wget https://github.com/DOCK-PI3/emulos-attract-config-rpi/archive/master.zip && unzip -o master.zip
 sudo rm /home/pi/master.zip
    sudo cp -R /home/pi/emulos-attract-config-rpi-master/EmulOS/roms/setup /home/pi/EmulOS/roms/
	 sudo chmod -R +x /home/pi/EmulOS/roms/setup/
	 sudo chown -R pi:pi /home/pi/EmulOS/roms/setup/
    sudo cp -R /home/pi/emulos-attract-config-rpi-master/EmulOS/emulosmenu/* /home/pi/EmulOS/emulosmenu/
  sudo chmod -R +x /home/pi/EmulOS/emulosmenu/
 sudo cp -R /home/pi/emulos-attract-config-rpi-master/opt/emulos/configs/all/* /opt/emulos/configs/all/
  sudo chmod -R +x /opt/emulos/configs/all/AM-Start.sh && sudo chmod -R +x /opt/emulos/configs/all/ES-Start.sh
 sudo cp -R /home/pi/emulos-attract-config-rpi-master/etc/samba/smb.conf /etc/samba/
  sudo cp -R /home/pi/emulos-attract-config-rpi-master/attract/* /home/pi/.attract/
  sudo chown -R pi:pi /home/pi/.attract/
  sudo chown -R pi:pi /opt/emulos/configs/all/
  # A�adir como sistema a ES y generar lista de roms,betatest
      local attract_dir="$(_get_configdir_attractmode)"
    [[ ! -d "$attract_dir" || ! -f /usr/bin/attract ]] && return 0

    local fullname="$1"
    local name="$2"
    local path="$3"
    local extensions="$4"
    local command="$5"
    local platform="$6"
    local theme="$7"

    # replace any / characters in fullname
    fullname="${fullname//\/ }"

    local config="$attract_dir/emulators/$fullname.cfg"
    iniConfig " " "" "$config"
    # replace %ROM% with "[romfilename]" and convert to array
    command=(${command//%ROM%/\"[romfilename]\"})
    iniSet "executable" "${command[0]}"
    iniSet "args" "${command[*]:1}"

    iniSet "rompath" "$path"
    iniSet "system" "$fullname"

    # extensions separated by semicolon
    extensions="${extensions// /;}"
    iniSet "romext" "$extensions"

    # snap path
    local snap="snap"
    [[ "$name" == "emulos" ]] && snap="icons"
    iniSet "artwork flyer" "$path/flyer"
    iniSet "artwork marquee" "$path/marquee"
    iniSet "artwork snap" "$path/$snap"
    iniSet "artwork wheel" "$path/wheel"

    chown $user:$user "$config"

    # if no gameslist, generate one
    if [[ ! -f "$attract_dir/romlists/$fullname.txt" ]]; then
        sudo -u $user attract --build-romlist "$fullname" -o "$fullname"
    fi

    local config="$attract_dir/attract.cfg"
    local tab=$'\t'
    if [[ -f "$config" ]] && ! grep -q "display$tab$fullname" "$config"; then
        cp "$config" "$config.bak"
        cat >>"$config" <<_EOF_
display${tab}$fullname
${tab}layout               Basic
${tab}romlist              $fullname
_EOF_
        chown $user:$user "$config"
    fi
dialog --infobox " Attract Mode se configuro correctamente!...\n\n Recuerde generar las listas de roms desde attract cuando meta juegos \n\n y para el menu setup si no le aparece! ," 370 370 ; sleep 10
# Borrar directorios de compilacion.....
sudo rm -r -f /home/pi/emulos-attract-config-rpi-master
# sudo reboot
# ---------------------------- #
}
main_menu
