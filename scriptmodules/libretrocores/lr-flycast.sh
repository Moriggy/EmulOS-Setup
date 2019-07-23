#!/usr/bin/env bash

# This file is part of The RetroPie Project | EDITADO Y MEJORADO POR EL EQUIPO MASOS-TEAM | EMULOS |
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-flycast"
rp_module_desc="Emulador par Dreamcast - Naomi - Atomiswave - Flycast port para libretro"
rp_module_help="Anteriormente llamado lr-reicast ahora lr-flycast\n\nDreamcast ROM Extensions: .cdi .gdi .chd, Naomi/Atomiswave ROM Extension: .lst .bin .zip\n\nCopia tus roms de Dreamcast en $romdir/dreamcast\n\nCopia tus roms de Atomiswave en $romdir/atomiswave\n\nCopia tus roms de Naomi en $romdir/naomi\n\nCopia las BIOS de Dreamcast dc_boot.bin y dc_flash.bin en $biosdir/dc\n\nCopia las BIOS de Naomi/Atomiswave naomi.zip y awbios.zip en $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/flycast/master/LICENSE"
rp_module_section="exp"
rp_module_flags="!mali !armv6"

function _update_hook_lr-flycast() {
    renameModule "lr-reicast" "lr-beetle-dc"
    renameModule "lr-beetle-dc" "lr-flycast"
}

function sources_lr-flycast() {
    gitPullOrClone "$md_build" https://github.com/libretro/flycast.git
    # don't override our C/CXXFLAGS
    sed -i "/^C.*FLAGS.*:=/d" Makefile
}

function build_lr-flycast() {
    make clean
    if isPlatform "rpi"; then
        # MAKEFLAGS replace removes any distcc from path, as it segfaults with cross compiler and lto
        MAKEFLAGS="${MAKEFLAGS/\/usr\/lib\/distcc:/}" make platform=rpi
    else
        make
    fi
    md_ret_require="$md_build/flycast_libretro.so"
}

function install_lr-flycast() {
    md_ret_files=(
        'flycast_libretro.so'
        'LICENSE'
    )
}

function configure_lr-flycast() {
    mkRomDir "dreamcast"
    mkRomDir "naomi"
    mkRomDir "atomiswave"
    ensureSystemretroconfig "dreamcast"
    ensureSystemretroconfig "naomi"
    ensureSystemretroconfig "atomiswave"

    mkUserDir "$biosdir/dc"

    # system-specific
    iniConfig " = " "" "$configdir/dreamcast/retroarch.cfg"
    iniSet "video_shared_context" "true"

    # segfaults on the rpi without redirecting stdin from </dev/null
    addEmulator 1 "$md_id" "dreamcast" "$md_inst/flycast_libretro.so </dev/null"
    addSystem "dreamcast"
    addEmulator 1 "$md_id" "naomi" "$md_inst/flycast_libretro.so </dev/null"
    addSystem "naomi"
    addEmulator 1 "$md_id" "atomiswave" "$md_inst/flycast_libretro.so </dev/null"
    addSystem "atomiswave"
}
