#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-picodrive"
rp_module_desc="Emulador de Sega 8/16 bits - picodrive (optimizado para arm) libretro core"
rp_module_help="ROM Extensions: .32x .iso .cue .sms .smd .bin .gen .md .sg .zip\n\nCopia tus roms de Megadrive / Genesis en $romdir/megadrive\nLas roms de MasterSystem en $romdir/mastersystem\nLas roms de Sega 32X en $romdir/sega32x y\nLas roms de SegaCD en $romdir/segacd\nSega CD requiere las BIOS us_scd1_9210.bin, eu_mcd1_9210.bin y jp_mcd1_9112.bin en $biosdir"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/picodrive/master/COPYING"
rp_module_section="main"

function sources_lr-picodrive() {
    gitPullOrClone "$md_build" https://github.com/libretro/picodrive.git
}

function build_lr-picodrive() {
    local params=()
    isPlatform "arm" && params+=(platform=armv ARM_ASM=1 use_fame=0 use_cyclone=1 use_sh2drc=1 use_svpdrc=1)
    if isPlatform "armv6"; then
        params+=(use_cz80=0 use_drz80=1)
    else
        params+=(use_cz80=1 use_drz80=0)
    fi
    make clean
    make -f Makefile.libretro "${params[@]}"
    md_ret_require="$md_build/picodrive_libretro.so"
}

function install_lr-picodrive() {
    md_ret_files=(
        'AUTHORS'
        'COPYING'
        'picodrive_libretro.so'
        'README'
    )
}

function configure_lr-picodrive() {
    local system
    local def
    for system in megadrive mastersystem segacd sega32x; do
        def=0
        # default on megadrive / mastersystem only on armv6 for performance
        [[ "$system" =~ megadrive|mastersystem ]] && isPlatform "arm6" && def=1
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator $def "$md_id" "$system" "$md_inst/picodrive_libretro.so"
        addSystem "$system"
    done
}
