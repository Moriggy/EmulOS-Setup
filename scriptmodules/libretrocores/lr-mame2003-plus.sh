#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mame2003-plus"
rp_module_desc="Emulador Arcade - actualización MAME 0.78 (2003) port para libretro con soporte adicional para el juego"
rp_module_help="ROM Extension: .zip\n\nCopia tus roms de MAME 0.78 (2003) en $romdir/mame-libretro o\n$romdir/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2003-plus-libretro/master/LICENSE.md"
rp_module_section="main"

function _get_dir_name_lr-mame2003-plus() {
    echo "mame2003-plus"
}

function _get_so_name_lr-mame2003-plus() {
    echo "mame2003_plus"
}

function sources_lr-mame2003-plus() {
    gitPullOrClone "$md_build" https://github.com/libretro/mame2003-plus-libretro.git
}

function build_lr-mame2003-plus() {
    build_lr-mame2003
}

function install_lr-mame2003-plus() {
    install_lr-mame2003
}

function configure_lr-mame2003-plus() {
    configure_lr-mame2003
}
