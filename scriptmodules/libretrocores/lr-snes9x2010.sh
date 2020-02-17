#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-snes9x2010"
rp_module_desc="Emulador de Super Nintendo - Snes9x 1.52 based port para libretro"
rp_module_help="Anteriormente llamado lr-snes9x-next\n\nROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopia tus roms de SNES en $romdir/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/snes9x2010/master/docs/snes9x-license.txt"
rp_module_section="opt arm=main"

function _update_hook_lr-snes9x2010() {
    # move from old location and update emulators.cfg
    renameModule "lr-snes9x-next" "lr-snes9x2010"
}

function sources_lr-snes9x2010() {
    gitPullOrClone "$md_build" https://github.com/libretro/snes9x2010.git
}

function build_lr-snes9x2010() {
    make -f Makefile.libretro clean
    local platform=""
    isPlatform "arm" && platform+="armv"
    isPlatform "neon" && platform+="neon"
    if [[ -n "$platform" ]]; then
        make -f Makefile.libretro platform="$platform"
    else
        make -f Makefile.libretro
    fi
    md_ret_require="$md_build/snes9x2010_libretro.so"
}

function install_lr-snes9x2010() {
    md_ret_files=(
        'snes9x2010_libretro.so'
        'docs'
    )
}

function configure_lr-snes9x2010() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    local def=0
    isPlatform "armv7" && def=1
    addEmulator $def "$md_id" "snes" "$md_inst/snes9x2010_libretro.so"
    addSystem "snes"
}
