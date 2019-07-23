#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-beetle-lynx"
rp_module_desc="Emulador de Atari Lynx - Mednafen Lynx Port para libretro, a su vez un fork de Handy"
rp_module_help="ROM Extensions: .lnx .zip\n\nCopia tus roms de Atari Lynx en $romdir/atarilynx\n\nCopia la BIOS lynxboot.img en $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-lynx-libretro/master/COPYING"
rp_module_section="opt"

function sources_lr-beetle-lynx() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-lynx-libretro.git
}

function build_lr-beetle-lynx() {
    make clean
    make
    md_ret_require="$md_build/mednafen_lynx_libretro.so"
}

function install_lr-beetle-lynx() {
    md_ret_files=(
        'mednafen_lynx_libretro.so'
    )
}

function configure_lr-beetle-lynx() {
    mkRomDir "atarilynx"
    ensureSystemretroconfig "atarilynx"

    addEmulator 0 "$md_id" "atarilynx" "$md_inst/mednafen_lynx_libretro.so"
    addSystem "atarilynx"
}
