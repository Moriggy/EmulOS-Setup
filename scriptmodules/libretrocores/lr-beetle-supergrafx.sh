#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-beetle-supergrafx"
rp_module_desc="Emulador de SuperGrafx / TG-16 - Mednafen PCE Fast port para libretro"
rp_module_help="ROM Extensions: .pce .ccd .cue .zip\n\nCopia tus roms de PC Engine / TurboGrafx en $romdir/pcengine\n\nCopia la BIOS syscard3.pce en $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-supergrafx-libretro/master/COPYING"
rp_module_section="main"

function sources_lr-beetle-supergrafx() {
    gitPullOrClone "$md_build" https://github.com/libretro/beetle-supergrafx-libretro.git
}

function build_lr-beetle-supergrafx() {
    make clean
    make
    md_ret_require="$md_build/mednafen_supergrafx_libretro.so"
}

function install_lr-beetle-supergrafx() {
    md_ret_files=(
        'mednafen_supergrafx_libretro.so'
    )
}

function configure_lr-beetle-supergrafx() {
  mkRomDir "supergrafx"
  ensureSystemretroconfig "supergrafx"

  addEmulator 0 "$md_id" "supergrafx" "$md_inst/mednafen_supergrafx_libretro.so"
  addSystem "supergrafx"

mkRomDir "tg16"
  ensureSystemretroconfig "tg16"

  addEmulator 0 "$md_id" "tg16" "$md_inst/mednafen_supergrafx_libretro.so"
  addSystem "tg16"
}
