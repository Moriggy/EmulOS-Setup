#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="steamcontroller"
rp_module_desc="Standalone Steam Controller Driver"
rp_module_help="Steam Controller Driver from https://github.com/ynsta/steamcontroller"
rp_module_licence="MIT https://raw.githubusercontent.com/ynsta/steamcontroller/master/LICENSE"
rp_module_section="driver"
rp_module_flags="noinstclean"

function depends_steamcontroller() {
    getDepends virtualenv python3-dev
}

function sources_steamcontroller() {
    gitPullOrClone "$md_inst" https://github.com/ynsta/steamcontroller.git
}

function install_steamcontroller() {
    cd "$md_inst"
    chown -R "$user:$user"  "$md_inst"
    sudo -u $user bash -c "\
        virtualenv -p python3 --no-site-packages \"$md_inst\"; \
        source bin/activate; \
        pip3 install libusb1; \
        python3 setup.py install; \
    "
}

function enable_steamcontroller() {
    local mode="$1"
    [[ -z "$mode" ]] && mode="xbox"

    local config="\"$md_inst/bin/sc-$mode.py\" start"

    disable_steamcontroller
    sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/rc.local
    printMsgs "dialog" "$md_id habilitado en /etc/rc.local con la siguiente configuración\n\n $config\n\nSe iniciará en el próximo arranque."
}

function disable_steamcontroller() {
    sed -i "/bin\/sc-.*.py/d" /etc/rc.local
}

function remove_steamcontroller() {
    disable_steamcontroller
    rm -f /etc/udev/rules.d/99-steam-controller.rules
}

function configure_steamcontroller() {
    cat >/etc/udev/rules.d/99-steam-controller.rules <<\_EOF_
# Steam controller keyboard/mouse mode
SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", GROUP="input", MODE="0660"

# Steam controller gamepad mode
KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
_EOF_
}

function gui_steamcontroller() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Elige una opción." 22 86 16)
    local options=(
        1 "Habilitar steamcontroller (modo xbox 360)"
        2 "Activar steamcontroller (modo de mouse/teclado de escritorio)"
        3 "Desactivar el controlador steamcontroller"
    )
    while true; do
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    enable_steamcontroller xbox
                    ;;
                2)
                    enable_steamcontroller desktop
                    ;;
                3)
                    disable_steamcontroller
                    printMsgs "dialog" "steamcontroller eliminado de /etc/rc.local"
                    ;;
            esac
        else
            break
        fi
    done
}
