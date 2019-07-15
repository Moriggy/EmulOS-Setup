#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ps3controller"
rp_module_desc="PS3 controller drivery emparejamiento via sixad"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/sixad/master/COPYING"
rp_module_section="driver"

function depends_ps3controller() {
    depends_bluetooth
    local depends=(checkinstall libusb-dev libbluetooth-dev joystick)
    getDepends "${depends[@]}"
}

function sources_ps3controller() {
    local branch="$1"
    [[ "$branch" == "gasia-only" ]] && branch="master"

    gitPullOrClone "$md_build/sixad" https://github.com/RetroPie/sixad.git $branch
}

function build_ps3controller() {
    local branch="$1"
    local params=("DEVICE_SHORT_NAME=1")
    [[ "$branch" == "gasia-only" ]] && params+=("GASIA_GAMEPAD_HACKS=1")

    cd sixad
    make clean
    make "${params[@]}"
    local bin
    for bin in sixad-bin sixpair sixad-sixaxis sixad-remote sixad-raw sixad-3in1; do
        md_ret_require+=("$md_build/sixad/bins/$bin")
    done
}

function install_ps3controller() {
    local branch="$1"
    [[ -z "$branch" ]] && branch="ps3"

    cd sixad
    checkinstall -y --fstrans=no

    echo "$branch" >"$md_inst/type.txt"

    # Disable timeouts
    iniConfig " = " "" "/etc/bluetooth/main.conf"
    iniSet "DiscoverableTimeout" "0"
    iniSet "PairableTimeout" "0"
}

function remove_ps3controller() {
    dpkg --purge sixad
    [[ -f /usr/sbin/bluetoothd ]] && chmod 755 /usr/sbin/bluetoothd
}

function pair_ps3controller() {
    local branch="$1"
    [[ -z "$branch" ]] && branch="ps3"

    if [[ ! -f "$md_inst/type.txt" || "$(<"$md_inst/type.txt")" != "$branch" ]]; then
        local mode
        for mode in sources build install clean; do
            rp_callModule ps3controller $mode $branch
        done
        return
    fi

    printMsgs "dialog" "Conecte su mando PS3 ahora o en cualquier momento a su conexión USB, para configurar la conexión Bluetooth.\n\nDespués desconecte su mando PS3 de su conexión USB y presiona el botón PS para conectarse a través de Bluetooth."
    # enable old behaviour. run "sixad-helper sixpair" "now" for users who do not read info text
    sixad-helper sixpair
}

function gui_ps3controller() {
    declare -A drivers
    drivers["ps3"]="official ps3"
    drivers["gasia"]="clone support gasia"
    drivers["gasia-only"]="gasia only"
    drivers["shanwan"]="clone support shanwan"

    printMsgs "dialog" "ADVERTENCIA: el controlador del mando ps3 desactiva parcialmente la pila estándar de Bluetooth para que los controladores Dual Shock se puedan emparejar correctamente. Aunque la pila de Bluetooth se reactiva temporalmente dentro del menú Bluetooth de EmulOS para permitir la compatibilidad con periféricos Bluetooth estándar, cualquier otro software que se base en la pila de Bluetooth completa no funcionará correctamente mientras el controlador del mando ps3 esté activo."
    local cmd=(dialog --backtitle "$__backtitle" --menu "Elige una opción:" 22 76 16)
    while true; do
        local i=1
        local options=()
        local installed
        local id
        for id in ps3 gasia gasia-only shanwan; do
            installed=""
            if [[ -f "$md_inst/type.txt" && "$(<"$md_inst/type.txt")" == "$id" ]]; then
                options+=("$i" "Emparejar mando PS3 (${drivers[$id]})")
            else
                options+=("$i" "Instalar driver PS3 (${drivers[$id]})")
            fi
            ((i++))
        done
        options+=(
            5 "Eliminar configuración mando PS3"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    rp_callModule "$md_id" pair
                    ;;
                2)
                    rp_callModule "$md_id" pair gasia
                    ;;
                3)
                    rp_callModule "$md_id" pair gasia-only
                    ;;
                4)
                    rp_callModule "$md_id" pair shanwan
                    ;;
                5)
                    rp_callModule "$md_id" remove
                    break
                    ;;
            esac
        else
            break
        fi
    done
}
