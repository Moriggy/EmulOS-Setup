#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-px68k"
rp_module_desc="Emulador de SHARP X68000"
rp_module_help="Necesitas copiar las BIOS de X68000 (iplrom30.dat, iplromco.dat, iplrom.dat, o iplromxv.dat), y el archivo fuente (cgrom.dat o cgrom.tmp) en $romdir/BIOS/keropi. Usa F12 para acceder al menú del emulador."
rp_module_section="exp"
rp_module_flags=""

function sources_lr-px68k() {
    gitPullOrClone "$md_build" https://github.com/libretro/px68k-libretro.git
}

function build_lr-px68k() {
    make clean
    make
    md_ret_require="$md_build/px68k_libretro.so"
}

function install_lr-px68k() {
    md_ret_files=(
        'px68k_libretro.so'
        'README.MD'
        'readme.txt'
    )
}

function configure_lr-px68k() {
    mkRomDir "x68000"
    ensureSystemretroconfig "x68000"

    mkUserDir "$biosdir/keropi"

    addEmulator 1 "$md_id" "x68000" "$md_inst/px68k_libretro.so"
    addSystem "x68000"
}
