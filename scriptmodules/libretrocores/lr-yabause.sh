#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-yabause"
rp_module_desc="Emulador de Sega Saturn - Yabause (optimizado) port para libretro"
rp_module_help="ROM Extensions: .iso .bin .zip\n\nCopia tus roms de Sega Saturn en $romdir/saturn\n\nCopia la BIOS saturn_bios.bin en $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/yabause/master/yabause/COPYING"
rp_module_section="exp"
rp_module_flags="!armv6"

function sources_lr-yabause() {
    gitPullOrClone "$md_build" https://github.com/libretro/yabause.git
}

function build_lr-yabause() {
    cd libretro
    make clean
    if isPlatform "neon"; then
        make platform=armvneonhardfloat
    else
        make
    fi
    md_ret_require="$md_build/libretro/yabause_libretro.so"
}

function install_lr-yabause() {
    md_ret_files=(
        'libretro/yabause_libretro.so'
        'yabause/AUTHORS'
        'yabause/COPYING'
        'yabause/ChangeLog'
        'yabause/AUTHORS'
        'yabause/GOALS'
        'yabause/README'
        'yabause/README.LIN'
    )
}

function configure_lr-yabause() {
    mkRomDir "saturn"
    ensureSystemretroconfig "saturn"

    addEmulator 1 "$md_id" "saturn" "$md_inst/yabause_libretro.so"
    addSystem "saturn"
}
