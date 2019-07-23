#!/usr/bin/env bash

# Este fichero es parte del Proyecto MasOS Team
#
# The EmulOS Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/Moriggy/EmulOS-Setup/master/LICENSE.md
#

rp_module_id="personalizaremulos"
rp_module_desc="Personalizar el sistema EmulOS"
rp_module_section=""

infobox="${infobox}___________________________________________________\n\n"
infobox="${infobox}\nHerramienta para personalizar EmulOS\n"
infobox="${infobox}\nMasOS Team no se hace responsable de un mal uso de estos scripts\n\n"
infobox="${infobox}\n"

dialog --backtitle "http://masos.dx.am		MasOS Team" \
--title "Personalizacion de EmulOS (by Moriggy)" \
--msgbox "${infobox}" 15 55

function main_menu() {

	local choice
    while true; do
        choice=$(dialog --backtitle "MasOS Team		Personalización de EmulOS (script hecho por Moriggy)" --title " MENU PRINCIPAL " \
            --ok-label OK --cancel-label Exit \
            --menu "Que acción te gustaría personalizar?" 25 75 20 \
						1 "Instalar Bezels" \
						2 "Vídeos de Carga de Roms" \
						3 "Overclock (SÓLO) Raspberry pi" \
						4 "Crear Colecciones de juegos" \
						2>&1 > /dev/tty)

        case "$choice" in
			1) bezels  ;;
			2) launching_videos  ;;
			3) overclock  ;;
			4) colecciones ;;
			*)  break ;;
        esac
    done
}

# Funcion para instalar bezels	#

function bezels() {

	source $scriptdir/scriptmodules/extras/scripts/MainBezels.sh

}

# Funcion para videos de carga	#

function launching_videos() {

	source $scriptdir/scriptmodules/extras/scripts/videoloading.sh

}

# Funcion para overclock	#

function overclock() {

	source $scriptdir/scriptmodules/extras/scripts/overclock.sh

}

# Funcion para crear colecciones  #

function colecciones() {

	source $scriptdir/scriptmodules/extras/scripts/escollections.sh

}

main_menu
