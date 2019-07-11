#!/bin/bash
# This script change CPU and GPU settings

infobox=""
infobox="${infobox}______________________________________________________________________________________\n\n"
infobox="${infobox}\n"
infobox="${infobox}Overclock RPI 3/3B+ on/off\n\n"
infobox="${infobox}\n"
infobox="${infobox}Advertencia: esta secuencia de comandos cambiara la configuracion de CPU y GPU. Utilizado bajo su propio riesgo.\n"
infobox="${infobox}\n"
infobox="${infobox}Debes tener disipadores y ventilador en tu RPI antes de ejecutar este script.\n"
infobox="${infobox}\n"
infobox="${infobox}Su sistema se reiniciara despues de ejecutar este script.\n"
infobox="${infobox}\n\n"
infobox="${infobox}**Habilitar en RPI3**\n"
infobox="${infobox}Overclock 1300 RPI3\n"
infobox="${infobox}Overclock 1350 RPI3\n"
infobox="${infobox}Overclock 1400 RPI3\n"
infobox="${infobox}\n"
infobox="${infobox}**Habilitar en RPI3B+**\n"
infobox="${infobox}Overclock 1475 RPI3B+\n"
infobox="${infobox}Overclock 1500 RPI3B+\n"
infobox="${infobox}Overclock 1550 RPI3B+\n"
infobox="${infobox}Overclock 1575 RPI3B+\n"
infobox="${infobox}\n"
infobox="${infobox}\n\n"
infobox="${infobox}**Deshabilitar**\nSin overclock, se eliminan todas las configuraciones de overclock"
infobox="${infobox}\n"
infobox="${infobox}\n"
infobox="${infobox}Advertencia !!! El overclock 1550 y 1575 no funciona en todos los pi3b+.\n"
infobox="${infobox}A veces, esta configuracióo alta necesita 2 o 3 arranques para funcionar.\n"
infobox="${infobox}"

dialog --backtitle "EmulOS Overclock RPI 3/3b+ on/off" \
--title "EmulOS Overclock By MasOS Team" \
--msgbox "${infobox}" 35 110

function main_menu() {
    local choice

    while true; do
        choice=$(dialog --backtitle "OVERCLOCK RPI" --title " MENU PRINCIPAL " \
            --ok-label OK --cancel-label Exit \
            --menu "Qué acción te gustaría realizar?" 25 75 20 \
            1 "RPI 3B -> Overclock 1300" \
            2 "RPI 3B -> Overclock 1350" \
      			3 "RPI 3B -> Overclock 1400" \
      			4 "RPI 3B+ -> Overclock 1475" \
      			5 "RPI 3B+ -> Overclock 1500" \
      			6 "RPI 3B+ -> Overclock 1550" \
      			7 "RPI 3B+ -> Overclock 1575" \
      			8 "Sin overclock" \
            2>&1 > /dev/tty)

        case "$choice" in
            1) overclock1300  ;;
            2) overclock1350  ;;
            3) overclock1400  ;;
            4) overclock1475  ;;
            5) overclock1500  ;;
      			6) overclock1550  ;;
      			7) overclock1575  ;;
            8) nooverclock  ;;
            *)  break ;;
        esac
    done
}


function overclock1300() {
	dialog --infobox "...Aplicando..." 3 20 ; sleep 2
	sudo /home/pi/EmulOS-Setup/scriptmodules/extras/scripts/overclock1300rpi3.sh
}

function overclock1350() {
	dialog --infobox "...Aplicando..." 3 20 ; sleep 2
	sudo /home/pi/EmulOS-Setup/scriptmodules/extras/scripts/overclock1350rpi3.sh
}

function overclock1400() {
	dialog --infobox "...Aplicando..." 3 20 ; sleep 2
	sudo /home/pi/EmulOS-Setup/scriptmodules/extras/scripts/overclock1400rpi3.sh
}

function overclock1475() {
	dialog --infobox "...Aplicando..." 3 20 ; sleep 2
	sudo /home/pi/EmulOS-Setup/scriptmodules/extras/scripts/overclock1475rpi3plus.sh
}

function overclock1500() {
	dialog --infobox "...Aplicando..." 3 20 ; sleep 2
	sudo /home/pi/EmulOS-Setup/scriptmodules/extras/scripts/overclock1500rpi3plus.sh
}

function overclock1550() {
	dialog --infobox "...Aplicando..." 3 20 ; sleep 2
	sudo /home/pi/EmulOS-Setup/scriptmodules/extras/scripts/overclock1550rpi3plus.sh
}

function overclock1575() {
	dialog --infobox "...Aplicando..." 3 20 ; sleep 2
	sudo /home/pi/EmulOS-Setup/scriptmodules/extras/scripts/overclock1575rpi3plus.sh
}

function nooverclock() {
	dialog --infobox "...Aplicando..." 3 20 ; sleep 2
	sudo /home/pi/EmulOS-Setup/scriptmodules/extras/scripts/nooverclock.sh
}

main_menu
