#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-genesis-plus-gx"
rp_module_desc="Emulador de Sega 8/16 bits - Genesis Plus (mejorado) port para libretro"
rp_module_help="ROM Extensions: .bin .cue .gen .gg .iso .md .sg .smd .sms .zip\nCopia tus roms de Game Gear en $romdir/gamegear\nLas roms de MasterSystem en $romdir/mastersystem\nLas roms de Megadrive / Genesis en $romdir/megadrive\nLas roms de SG-1000 en $romdir/sg-1000\nLas roms de SegaCD en $romdir/segacd\nSega CD necesita las BIOS bios_CD_U.bin, bios_CD_E.bin y bios_CD_J.bin en $biosdir"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/Genesis-Plus-GX/master/LICENSE.txt"
rp_module_section="main"

function sources_lr-genesis-plus-gx() {
    gitPullOrClone "$md_build" https://github.com/libretro/Genesis-Plus-GX.git
}

function build_lr-genesis-plus-gx() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/genesis_plus_gx_libretro.so"
}

function install_lr-genesis-plus-gx() {
    md_ret_files=(
        'genesis_plus_gx_libretro.so'
        'HISTORY.txt'
        'LICENSE.txt'
        'README.md'
    )
}

function configure_lr-genesis-plus-gx() {
    local system
    local def
    for system in gamegear mastersystem megadrive sg-1000 segacd; do
        def=0
        [[ "$system" == "gamegear" || "$system" == "sg-1000" ]] && def=1
        # always default emulator for non armv6
        ! isPlatform "armv6" && def=1
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator "$def" "$md_id" "$system" "$md_inst/genesis_plus_gx_libretro.so"
        addSystem "$system"
    done
}
