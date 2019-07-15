#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="snesdev"
rp_module_desc="SNESDev (Controlador para el Adaptador-GPIO de EmulOS)"
rp_module_section="driver"
rp_module_flags="noinstclean"

function sources_snesdev() {
    gitPullOrClone "$md_inst" https://github.com/petrockblog/SNESDev-RPi.git
}

function build_snesdev() {
    cd "$md_inst"
    make -j1
    md_ret_require="$md_inst/src/SNESDev"
}

function install_snesdev() {
    cd "$md_inst"
    make install
}

# start SNESDev on boot and configure RetroArch input settings
function enable_at_start_snesdev() {
    local mode="$1"
    iniConfig "=" "" "/etc/snesdev.cfg"
    clear
    printHeading "Enabling SNESDev on boot."

    case "$mode" in
        1)
            iniSet "button_enabled" "0"
            iniSet "gamepad1_enabled" "1"
            iniSet "gamepad2_enabled" "1"
            ;;
        2)
            iniSet "button_enabled" "1"
            iniSet "gamepad1_enabled" "0"
            iniSet "gamepad2_enabled" "0"
            ;;
        3)
            iniSet "button_enabled" "1"
            iniSet "gamepad1_enabled" "1"
            iniSet "gamepad2_enabled" "1"
            ;;
        *)
            echo "[enable_at_start_snesdev] No entiendo lo que está pasando aquí."
            ;;
    esac

}

function set_adapter_version_snesdev() {
    local ver="$1"
    iniConfig "=" "" "/etc/snesdev.cfg"
    if [[ "$ver" -eq 1 ]]; then
        iniSet "adapter_version" "1x"
    else
        iniSet "adapter_version" "2x"
    fi
}

function remove_snesdev() {
    make -C "$md_inst" uninstallservice
    make -C "$md_inst" uninstall
}

function gui_snesdev() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
    local options=(
        1 "Habilitar SNESDev en el arranque y la asignación de teclado SNESDev (campos de votación y botón)"
        2 "Habilitar SNESDev en el arranque y la asignación de teclado SNESDev (solo sondeando los pads)"
        3 "Habilitar SNESDev en el arranque y la asignación de teclado SNESDev (botón de solo encuesta)"
        4 "Cambiar a la versión del adaptador 1.X"
        5 "Cambiar a la versión del adaptador 2.X"
        D "Deshabilitar SNESDev en el arranque y la asignación de teclado SNESDev"
    )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
                enable_at_start_snesdev 3
                make -C "$md_inst" installservice
                printMsgs "dialog" "SNESDev habilitado en el arranque (pads de sondeo y botón)."
                ;;
            2)
                enable_at_start_snesdev 1
                make -C "$md_inst" installservice
                printMsgs "dialog" "Habilitado SNESDev en el arranque (sondeo solo pads)."
                ;;
            3)
                enable_at_start_snesdev 2
                make -C "$md_inst" installservice
                printMsgs "dialog" "Habilitado SNESDev en el arranque (botón de solo sondeo)."
                ;;
            4)
                set_adapter_version_snesdev 1
                printMsgs "dialog" "Cambiado a la versión del adaptador 1.X."
                ;;
            5)
                set_adapter_version_snesdev 2
                printMsgs "dialog" "Cambiado a la versión del adaptador 2.X.."
                ;;
            D)
                make -C "$md_inst" uninstallservice
                printMsgs "dialog" "Deshabilitado SNESDev en el arranque."
                ;;
        esac
    fi
}
