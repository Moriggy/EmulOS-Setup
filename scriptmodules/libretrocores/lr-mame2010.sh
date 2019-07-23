#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mame2010"
rp_module_desc="Emulador Arcade - MAME 0.139 (2010) port para libretro"
rp_module_help="ROM Extension: .zip\n\nCopia tus roms de MAME 0.139 (2010) en $romdir/mame-libretro o\n$romdir/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2010-libretro/master/docs/license.txt"
rp_module_section="main"

function sources_lr-mame2010() {
    gitPullOrClone "$md_build" https://github.com/libretro/mame2010-libretro.git
}

function build_lr-mame2010() {
    rpSwap on 750
    make clean
    local params=()
    isPlatform "arm" && params+=("VRENDER=soft" "ARM_ENABLED=1")
    make "${params[@]}" ARCHOPTS="$CFLAGS" buildtools
    make "${params[@]}" ARCHOPTS="$CFLAGS"
    rpSwap off
    md_ret_require="$md_build/mame2010_libretro.so"
}

function install_lr-mame2010() {
    md_ret_files=(
        'mame2010_libretro.so'
        'README.md'
    )
}

function configure_lr-mame2010() {
    local system
    for system in arcade mame-libretro; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mame2010_libretro.so"
        addSystem "$system"
    done
}
