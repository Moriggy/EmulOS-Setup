#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xboxdrv"
rp_module_desc="Xbox / Xbox 360 gamepad driver"
rp_module_licence="GPL3 https://raw.githubusercontent.com/zerojay/xboxdrv/stable/COPYING"
rp_module_section="driver"

function def_controllers_xboxdrv() {
    echo "2"
}

function def_deadzone_xboxdrv() {
    echo "4000"
}

function depends_xboxdrv() {
    getDepends libboost-dev libusb-1.0-0-dev libudev-dev libx11-dev scons pkg-config x11proto-core-dev libdbus-glib-1-dev
}

function sources_xboxdrv() {
    gitPullOrClone "$md_build" https://github.com/zerojay/xboxdrv.git stable
}

function build_xboxdrv() {
    scons
}

function install_xboxdrv() {
    make install PREFIX="$md_inst"
}

function enable_xboxdrv() {
    local controllers="$1"
    local deadzone="$2"

    [[ -z "$controllers" ]] && controllers="$(def_controllers_xboxdrv)"
    [[ -z "$deadzone" ]] && deadzone="$(def_deadzone_xboxdrv)"

    local config="\"$md_inst/bin/xboxdrv\" --daemon --detach --dbus disabled --detach-kernel-driver"

    local i
    for (( i=0; i<$controllers; i++)); do
        [[ $i -gt 0 ]] && config+=" --next-controller"
        config+=" --id $i --led $((i+2)) --deadzone $deadzone --silent --trigger-as-button"
    done

    if grep -q "xboxdrv" /etc/rc.local; then
        dialog --yesno "xboxdrv ya está habilitado en /etc/rc.local con la siguiente configuración. ¿Quieres actualizarlo?\n\n$(grep "xboxdrv" /etc/rc.local)" 22 76 2>&1 >/dev/tty || return
    fi

    sed -i "/xboxdrv/d" /etc/rc.local
    sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/rc.local
    printMsgs "dialog" "xboxdrv habilitado en /etc/rc.local con la siguiente configuración\n\n $config\n\nSe iniciará en el próximo arranque."
}

function disable_xboxdrv() {
    sed -i "/xboxdrv/d" /etc/rc.local
    printMsgs "dialog" "Se ha eliminado la configuración de xboxdrv en /etc/rc.local."
}

function controllers_xboxdrv() {
    local controllers="$1"

    [[ -z "$controllers" ]] && controllers="$(def_controllers_xboxdrv)"

    local cmd=(dialog --backtitle "$__backtitle" --default-item "$controllers" --menu "Seleccione el número de mandos para habilitar" 22 86 16)
    local options=(
        1 "1 mando"
        2 "2 mandos"
        3 "3 mandos"
        4 "4 mandos"
    )

    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        controllers="$choice"
    fi

    echo "$controllers"
}

function deadzone_xboxdrv() {
    local deadzone="$1"

    [[ -z "$deadzone" ]] && deadzone="$(def_deadzone_xboxdrv)"

    local zones=()
    local options=()
    local i
    local label
    local default
    for i in {0..12}; do
        zones[i]=$((i*500))
        [[ ${zones[i]} -eq $deadzone ]] && default=$i
        label="0-${zones[i]}"
        [[ "$i" -eq 0 ]] && label="No Deadzone"
        options+=($i "$label")
    done

    local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Selecciona el rango de tu zona muerta analógica." 22 86 16)

    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        deadzone="${zones[$choice]}"
    fi

    echo "$deadzone"
}

function configure_xboxdrv() {
    # make sure existing configs will point to the new xboxdrv
    sed -i "s|^xboxdrv|\"$md_inst/bin/xboxdrv\"|" /etc/rc.local
}

function gui_xboxdrv() {
    if [[ ! -f "$md_inst/bin/xboxdrv" ]]; then
        if [[ $__has_binaries -eq 1 ]]; then
            rp_callModule "$md_id" depends
            rp_callModule "$md_id" install_bin
            rp_callModule "$md_id" configure
        else
            rp_callModule "$md_id"
        fi
    fi
    iniConfig "=" "" "/boot/config.txt"

    local controllers="$(def_controllers_xboxdrv)"
    local deadzone="$(def_deadzone_xboxdrv)"

    local cmd=(dialog --backtitle "$__backtitle" --menu "Elige una opción." 22 86 16)

    while true; do
        local options=(
            1 "Activar xboxdrv"
            2 "Desactivar xboxdrv"
            3 "Establecer el número de controladores para habilitar (actualmente: $controllers)"
            4 "Establecer la zona muerta del stick analógico (actualmente: $deadzone)"
            5 "Establecer dwc_otg.speed = 1 en /boot/config.txt"
            6 "Elimina dwc_otg.speed = 1 de /boot/config.txt"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then

            case "$choice" in
                1)
                    enable_xboxdrv "$controllers" "$deadzone"
                    ;;
                2)
                    disable_xboxdrv
                    ;;
                3)
                    controllers=$(controllers_xboxdrv $controllers)
                    ;;
                4)
                    deadzone=$(deadzone_xboxdrv $deadzone)
                    ;;
                5)
                    iniSet "dwc_otg.speed" "1"
                    printMsgs "dialog" "dwc_otg.speed=1 se ha establecido en /boot/config.txt"
                    ;;
                6)
                    iniDel "dwc_otg.speed"
                    printMsgs "dialog" "dwc_otg.speed=1 ha sido eliminado de /boot/config.txt"
                    ;;
            esac
        else
            break
        fi
    done
  }
