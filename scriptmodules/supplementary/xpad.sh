#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xpad"
rp_module_desc="Controlador del kernel de Linux actualizado"
rp_module_help="Este es el último controlador de Xpad de https://github.com/paroj/xpad\n\nEl controlador ha sido parcheado para permitir que los triggers se asignen a los botones de cualquier mando y esto se ha habilitado de forma predeterminada.\n\nEsta solución mapeando los desencadenantes en EmulationStation.\n\nSi deseas el comportamiento anterior del desencadenador, edita /etc/modprobe.d/xpad.conf y configura triggers_to_buttons = 0"
rp_module_licence="GPL2 https://www.kernel.org/pub/linux/kernel/COPYING"
rp_module_section="driver"
rp_module_flags="noinstclean !mali"

function _version_xpad() {
    echo "0.4"
}

function depends_xpad() {
    local depends=(dkms)
    isPlatform "rpi" && depends+=(raspberrypi-kernel-headers)
    isPlatform "x11" && depends+=(linux-headers-generic)
    getDepends "${depends[@]}"
}

function sources_xpad() {
    rm -rf "$md_inst"
    gitPullOrClone "$md_inst" https://github.com/paroj/xpad.git
    cd "$md_inst"
    # LED support (as disabled currently in packaged RPI kernel) and allow forcing MAP_TRIGGERS_TO_BUTTONS
    applyPatch "$md_data/01_enable_leds_and_trigmapping.diff"
}

function build_xpad() {
    dkmsManager install xpad "$(_version_xpad)"
}

function remove_xpad() {
    dkmsManager remove xpad "$(_version_xpad)"
    rm -f /etc/modprobe.d/xpad.conf
}

function configure_xpad() {
    [[ "$md_mode" == "remove" ]] && return

    if [[ ! -f /etc/modprobe.d/xpad.conf ]]; then
        echo "options xpad triggers_to_buttons=1" >/etc/modprobe.d/xpad.conf
    fi
    dkmsManager reload xpad "$(_version_xpad)"
}
