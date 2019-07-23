#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-o2em"
rp_module_desc="Emulador de Odyssey 2 / Videopac - O2EM port para libretro"
rp_module_help="ROM Extensions: .bin .zip\n\nCopia tus roms de Odyssey 2 / Videopac en $romdir/videopac\n\nCopia la BIOS o2rom.bin en $biosdir"
rp_module_licence="OTHER"
rp_module_section="opt"

function sources_lr-o2em() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-o2em
}

function build_lr-o2em() {
    make clean
    make
    md_ret_require="$md_build/o2em_libretro.so"
}

function install_lr-o2em() {
    md_ret_files=(
        'o2em_libretro.so'
        'README.md'
    )
}

function configure_lr-o2em() {
    mkRomDir "videopac"
    ensureSystemretroconfig "videopac"

    addEmulator 1 "$md_id" "videopac" "$md_inst/o2em_libretro.so"
    addSystem "videopac"
}
