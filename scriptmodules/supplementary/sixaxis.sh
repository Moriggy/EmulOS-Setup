#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="sixaxis"
rp_module_desc="Servicio auxiliar para instalar y configurar los controladores más recientes para los controladores DualShock oficiales y de terceros (reemplazo del controlador ps3)\n\nNota: Para los controladores de terceros de Shanwan/GASIA, habilite el soporte de terceros en las opciones de configuración.\n\nPara emparejar mandos, use el menú EmulOS Bluetooth, seleccione 'Registrar y conectar ...', luego siga las instrucciones en pantalla."
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/sixaxis/master/COPYING"
rp_module_section="driver"

function depends_sixaxis() {
    getDepends checkinstall libevdev-tools

    rp_callModule ps3controller remove
}

function sources_sixaxis() {
    gitPullOrClone "$md_build/sixaxis" https://github.com/RetroPie/sixaxis.git
}

function build_sixaxis() {
    cd sixaxis
    make clean
    make
    md_ret_require="$md_build/sixaxis/bins/sixaxis-timeout"
}

function gui_sixaxis() {
    local sixaxis_config="$md_conf_root/all/sixaxis_timeout.cfg"
    local cmd=(dialog --backtitle "$__backtitle" --menu "Elige una opción." 22 86 16)
    local options=(
        1 "Habilitar soporte para controladores de terceros"
        2 "Deshabilitar el soporte para controladores de terceros"
        3 "Configurar el tiempo de espera del controlador"
    )
    local timeout_options=(
        0 "Sin tiempo de espera"
        300 "5 minutos"
        600 "10 minutos"
        900 "15 minutos"
        1200 "20 minutos"
        1800 "30 minutos"
    )
    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    rp_callModule "customhidsony"
                    ;;
                2)  rp_callModule "customhidsony" remove
                    rp_callModule "custombluez" remove
                    ;;
                3)
                    local timeout_choice=$("${cmd[@]}" "${timeout_options[@]}" 2>&1 >/dev/tty)
                    if [[ -n "$timeout_choice" ]] && [[ -f "$sixaxis_config" ]]; then
                        case "$timeout_choice" in
                            *)
                                iniConfig "=" "" "$sixaxis_config"
                                iniSet "SIXAXIS_TIMEOUT" "$timeout_choice"
                                systemctl restart sixaxis@/* &>/dev/null
                                ;;
                        esac
                    fi
                    ;;
            esac
        else
            break
        fi
    done
}

function install_sixaxis() {
    cd sixaxis
    checkinstall -y --fstrans=no
}

function configure_sixaxis() {
    [[ "$md_mode" == "remove" ]] && return

    local sixaxis_config="$(mktemp)"

    echo "# Establezca el tiempo de espera de su mando preferido en segundos (0 para deshabilitar)" >"$sixaxis_config"
    iniConfig "=" "" "$sixaxis_config"
    iniSet "SIXAXIS_TIMEOUT" "600"
    copyDefaultConfig "$sixaxis_config" "$md_conf_root/all/sixaxis_timeout.cfg"
    rm "$sixaxis_config"
}

function remove_sixaxis() {
    dpkg --purge sixaxis
}
