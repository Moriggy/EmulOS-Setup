#!/usr/bin/env bash
rp_module_id="emulosextrasall"
rp_module_desc="EmulOS Herramientas y utils"
rp_module_section=""
infobox="${infobox}\n_______________________________________________________\n\n"
infobox="${infobox}\nEmulOS Herramientas y extras para el menu de ES ect.."
infobox="${infobox}\ny reparador de permisos para la version PC,IDIOMAS y mucho mas.."
infobox="${infobox}\n_______________________________________________________\n\n"
infobox="${infobox}\nIDIOMA español para emulationstation-dev CMake y Make auto ....new,"
infobox="${infobox}\neste script es para las instalaciones desde 0 ,funciona en rpi y pc \n"
infobox="${infobox}sin importar el nombre d usuario o sistema,solo tienen que tener instalado \n"
infobox="${infobox}emulationstation-dev ,lo pueden instalar en Administrar paquetes/Paquetes experimentales\n"
infobox="${infobox}Se recomienda instalacion de EXTRAS para el menu solo en raspberry pi....\n"
infobox="${infobox}\nEn PC puede instalar los extras si usa de nombre de usuario pi"

dialog --backtitle "EmulOS extras y herramientas base" \
--title "EmulOS EXTRAS ,herramientas y raparador de permisos en PC(The MasOS TEAM)" \
--msgbox "${infobox}" 35 110



function main_menu() {
    local choice

    while true; do
        choice=$(dialog --backtitle "$BACKTITLE" --title " MAIN MENU " \
            --ok-label OK --cancel-label Exit \
            --menu "Que accion te gustaria realizar?" 25 75 20 \
            100 "-------------- Para RPI ----------------" \
            1 "RPI EXTRAS para el menu de EmulationStation" \
            2 "RPI EmulationStation instalar idioma español" \
            99 "RPI AttractMode Instalador/Configurador" \
            200 "-------------- Para PC ----------------" \
            3 "PC EmulOS EXTRAS para el menu de EmulationStation" \
            4 "PC Reparar permisos en EmulOS" \
            5 "PC EmulationStation-dev idioma español para Ubuntu 16.04.5" \
            300  "------------- DEV BETAS Raspberry RPI y PC -----------------" \
            6 "IDIOMA español para emulationstation-dev instalaciones desde 0" \
            7 "BETA Instalar iconos Originales de EmulationStation" \
            8 "BETA EXTRAS PARA PC o RPI EmulationStation" \
            2>&1 > /dev/tty)

        case "$choice" in
			100) separador_menu  ;;
			1) emulosmenu_extras  ;;
            2) pi_spanish ;;
			99) pi_attractmode_ic ;;
			200) separador_menu  ;;
			3) emulosmenu_extrasPC ;;
			4) permisos_pc  ;;
			5) pc_spanish  ;;
			300) separador_menu  ;;
			6) idioma_spanish_all ;;
			7) esicons_origi ;;
			8) extras_all_auto ;;
			*)  break ;;
        esac
    done
}


function separador_menu() {                                          #
dialog --infobox "... Separador para el menu, sin funcion ..." 30 55 ; sleep 3
}

function pi_attractmode_ic() {                                          #
dialog --infobox "... Script instalador y configurador para attract mode ..." 30 55 ; sleep 3
cd && sudo EmulOS-Setup/tools/attractmode.sh
}

#########################################################################
# Funcion EXTRAs Menu ES para EmulOS ;-) #
function emulosmenu_extras() {                                          #
dialog --infobox " EmulOS opciones Extras en rpi para el menu de ES..." 30 55 ; sleep 5
cd
sudo cp /home/pi/EmulOS-Setup/scriptmodules/extras/gamelist.xml /opt/emulos/configs/all/emulationstation/gamelists/emulos/
sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/supplementary/emulosmenu/* /home/pi/EmulOS/emulosmenu/
# sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/supplementary/emulosmenu/icons /home/pi/EmulOS/emulosmenu
sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/extras/scripts /home/pi/EmulOS/
sudo chmod -R +x /home/pi/EmulOS
sudo chmod -R +x /opt/
sudo mkdir /home/pi/EmulOS/roms/music
sudo chown -R pi:pi /home/pi/EmulOS
dialog --infobox " Las opciones Extras estan instaladas,reiniciando el sistema en 5seg ..." 30 55 ; sleep 5
sudo reboot
# ---------------------------- #
}

#########################################################################
# Funcion PC EXTRAs Menu ES para EmulOS ;-) #
function emulosmenu_extrasPC() {                                          #
dialog --infobox " PC EmulOS opciones Extras para el menu de ES..." 30 55 ; sleep 5
cd
sudo cp ~/EmulOS-Setup/scriptmodules/extras/gamelist.xml /opt/emulos/configs/all/emulationstation/gamelists/emulos/
sudo cp -R ~/EmulOS-Setup/scriptmodules/supplementary/emulosmenu/* ~/EmulOS/emulosmenu/
sudo cp -R ~/EmulOS-Setup/scriptmodules/extras/scripts ~/EmulOS/
sudo chmod -R +x ~/EmulOS
sudo chmod -R +x /opt/
sudo mkdir ~/EmulOS/roms/music
sudo chown -R $user:$user ~/EmulOS
dialog --infobox " Las opciones Extras estan instaladas,reiniciando el sistema en 5seg ..." 30 55 ; sleep 5
sudo reboot
# ---------------------------- #
}

#########################################################################
# Funcion Reparar permisos en EmulOS PC ;-) #
function permisos_pc() {                                          #
dialog --infobox " Repara los permisos en el directorio themes y overlays para que puedan ser editados los ficheros...\n\n" 30 55 ; sleep 5
cd
sudo chown -R $user:$user /etc/emulationstation/themes/
sudo chown -R $user:$user /opt/emulos/configs/
dialog --infobox " Los permisos fueron reparados ..." 30 55 ; sleep 5
# ---------------------------- #
}

#########################################################################
# Raspberry pi instalar idioma español en ES #
function pi_spanish() {                                          #
dialog --infobox " Raspberry pi - instalar idioma español en ES..." 30 55 ; sleep 5
cd
sudo killall emulationstation
sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/extras/es_idioma/locale/ /opt/emulos/supplementary/emulationstation/
sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/extras/es_idioma/resources/ /opt/emulos/supplementary/emulationstation/
sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/extras/es_idioma/* /opt/emulos/supplementary/emulationstation/
dialog --infobox " El idioma se instalo correctamente ,reiniciando el sistema en 5seg ..." 30 55 ; sleep 5
sudo reboot
# ---------------------------- #
}

#########################################################################
# PC instalar idioma español en ES #
function pc_spanish() {                                          #
dialog --infobox " PC Ubuntu 16.04.5 - instalar idioma español en ES..." 30 55 ; sleep 5
cd
sudo killall emulationstation
sudo cp -R ~/EmulOS-Setup/scriptmodules/extras/es_idiomaPC/locale/ /opt/emulos/supplementary/emulationstation/
sudo cp -R ~/EmulOS-Setup/scriptmodules/extras/es_idiomaPC/resources/ /opt/emulos/supplementary/emulationstation/
sudo cp ~/EmulOS-Setup/scriptmodules/extras/es_idiomaPC/* /opt/emulos/supplementary/emulationstation/
dialog --infobox " El idioma se instalo correctamente ,reiniciando el sistema en 5seg ..." 30 55 ; sleep 5
sudo reboot
# ---------------------------- #
}
                                                                                                                     #
######################################################################################################################
# Instalar idioma español en ES-dev all system - CMake y Make # Dependencias emulationstation-dev y libboost-all-dev#
function idioma_spanish_all() {                                          #############################################
dialog --infobox " CMAKE Y MAKE instalar idioma español en emulationstation-dev. Recuerde ejecutar el script desde consola y con emulationstation inactivo.." 30 55 ; sleep 5
cd && git clone --recursive https://github.com/DOCK-PI3/EmulationStation.git
cd EmulationStation && mkdir src && cd src
cmake .. && make
sudo cp -R ~/EmulationStation/locale/ /opt/emulos/supplementary/emulationstation-dev/
sudo cp -R ~/EmulationStation/resources/ /opt/emulos/supplementary/emulationstation-dev/
sudo cp ~/EmulationStation/emulationstation /opt/emulos/supplementary/emulationstation-dev/
sudo rm -R ~/EmulationStation
sudo chown -R $user:$user /opt/emulos/supplementary/emulationstation-dev/
dialog --infobox " El idioma se instalo correctamente ,reiniciando el sistema en 5seg ..." 30 55 ; sleep 5
sudo reboot
# ---------------------------- #
}

#########################################################################
# instalar ES icons origi #
function esicons_origi() {                                          #
dialog --infobox "... instalar ES icons originales ..." 30 55 ; sleep 5
cd && mkdir temporal
cd temporal && git clone https://github.com/DOCK-PI3/es-iconsthemes-ORIGINAL.git
sudo cp -R ~/temporal/es-iconsthemes-ORIGINAL/*.svg /opt/emulos/supplementary/emulationstation/resources/help/
sudo cp -R ~/temporal/es-iconsthemes-ORIGINAL/*.svg /opt/emulos/supplementary/emulationstation-dev/resources/help/
sudo chown -R $user:$user /opt/emulos/supplementary/emulationstation/
sudo chown -R $user:$user /opt/emulos/supplementary/emulationstation-dev/
sudo rm -R ~/temporal
dialog --infobox "... Iconos originales instalados ,reinicie ES para ver los nuevos iconos..." 30 55 ; sleep 5
# ---------------------------- #
}

#########################################################################
# Instalador de extras segun el sistema ,para PC y RPI #
function extras_all_auto() {

        if [[ -f /home/pi/EmulOS/emulosmenu/raspiconfig.rp ]]; then
			cd
			sudo cp /home/pi/EmulOS-Setup/scriptmodules/extras/gamelist.xml /opt/emulos/configs/all/emulationstation/gamelists/emulos/
			sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/supplementary/emulosmenu/* /home/pi/EmulOS/emulosmenu/
			sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/extras/scripts /home/pi/EmulOS/
			sudo chmod -R +x /home/pi/EmulOS
			sudo chmod -R +x /opt/
			sudo mkdir /home/pi/EmulOS/roms/music
			sudo chown -R pi:pi /home/pi/EmulOS
    else
        if [[ -f $home/.config/autostart/emulos.desktop ]]; then
		cd
		sudo cp ~/EmulOS-Setup/scriptmodules/extras/gamelist.xml /opt/emulos/configs/all/emulationstation/gamelists/emulos/
		sudo cp -R ~/EmulOS-Setup/scriptmodules/supplementary/emulosmenu/* ~/EmulOS/emulosmenu/
		sudo cp -R ~/EmulOS-Setup/scriptmodules/extras/scripts ~/EmulOS/
		sudo chmod -R +x ~/EmulOS
		sudo chmod -R +x /opt/
		sudo mkdir ~/EmulOS/roms/music
		sudo chown -R $user:$user ~/EmulOS
	fi
		fi
# ---------------------------- #
}

main_menu
