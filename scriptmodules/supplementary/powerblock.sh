#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="powerblock"
rp_module_desc="PowerBlock Driver"
rp_module_section="driver"
rp_module_flags="noinstclean"
rp_module_help="Ten en cuenta que necesita habilitar o deshabilitar manualmente el servicio PowerBlock en la sección Configuración. IMPORTANTE: si el servicio está habilitado y la función del interruptor de encendido está habilitada (que es la configuración predeterminada) en el archivo de configuración, debe tener un interruptor conectado al PowerBlock."

rp_module_flags="noinstclean !all rpi"

function depends_powerblock() {
    local depends=(cmake doxygen)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)

    getDepends "${depends[@]}"
}

function sources_powerblock() {
    if [[ -d "$md_inst" ]]; then
        git -C "$md_inst" reset --hard  # ensure that no local changes exist
    fi
    gitPullOrClone "$md_inst" https://github.com/petrockblog/PowerBlock.git
}

function install_powerblock() {
    cd "$md_inst"
    bash install.sh
}

function remove_powerblock() {
    cd "$md_inst"
    bash uninstall.sh
}

function gui_powerblock() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Elige una opcion." 22 86 16)
    local options=(
        1 "Habilitar driver PowerBlock"
        2 "Deshabilitar driver PowerBlock"

    )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
                install_powerblock
                printMsgs "dialog" "Habilitado driver PowerBlock."
                ;;
            2)
                remove_powerblock
                printMsgs "dialog" "Deshabilitado driver PowerBlock."
                ;;
        esac
    fi
}
