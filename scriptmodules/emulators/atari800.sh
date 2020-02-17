#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="atari800"
rp_module_desc="Emulador Atari 8-bit/800/5200"
rp_module_licence="GPL2 https://sourceforge.net/p/atari800/source/ci/master/tree/COPYING"
rp_module_help="ROM Extensions: .a52 .bas .bin .car .xex .atr .xfd .dcm .atr.gz .xfd.gz\n\nCopia tus juegos de Atari800 en $romdir/atari800\n\nCopia tus juegos de Atari 5200 en $romdir/atari5200 Debes copiar los archivos de BIOS Atari 800/5200 (5200.ROM, ATARIBAS.ROM, ATARIOSB.ROM y ATARIXL.ROM) en la carpeta $biosdir y luego, en el primer inicio, configúralo para escanear esa carpeta en busca de roms (F1 -> Configuración del emulador -> Configuración del sistema Rom)"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_atari800() {
    local depends=(libsdl1.2-dev autoconf automake zlib1g-dev libpng-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}"
}

function sources_atari800() {
    gitPullOrClone "$md_build" "https://github.com/atari800/atari800.git" ATARI800_4_2_0
    if isPlatform "rpi"; then
        applyPatch "$md_data/01_rpi_fixes.diff"
    fi
}

function build_atari800() {
    local params=()
    ./autogen.sh
    isPlatform "videocore" && params+=(--target=rpi)
    ./configure --prefix="$md_inst" ${params[@]}
    make clean
    make
    md_ret_require="$md_build/src/atari800"
}

function install_atari800() {
    cd src
    make install
}

function configure_atari800() {
    local params=()
    isPlatform "kms" && params+=("-fullscreen" "-fs-width %XRES%" "-fs-height %YRES%")

    mkRomDir "atari800"
    mkRomDir "atari5200"

    if [[ "$md_mode" == "install" ]]; then
        mkUserDir "$md_conf_root/atari800"

        # move old config if exists to new location
        if [[ -f "$md_conf_root/atari800.cfg" ]]; then
            mv "$md_conf_root/atari800.cfg" "$md_conf_root/atari800/atari800.cfg"
        fi
        moveConfigFile "$home/.atari800.cfg" "$md_conf_root/atari800/atari800.cfg"

        # copy launch script (used for unpacking archives)
        sed "s#EMULATOR#/bin/$md_id#" "$scriptdir/scriptmodules/$md_type/atari800/atari800.sh" >"$md_inst/$md_id.sh"
        chmod a+x "$md_inst/$md_id.sh"
    fi

    addEmulator 1 "atari800" "atari800" "$md_inst/atari800.sh %ROM% ${params[*]}"
    addEmulator 1 "atari800-800" "atari800" "$md_inst/atari800.sh %ROM% ${params[*]} -atari"
    addEmulator 1 "atari800-800xl" "atari800" "$md_inst/atari800.sh %ROM% ${params[*]} -xl"
    addEmulator 1 "atari800-130xe" "atari800" "$md_inst/atari800.sh %ROM% ${params[*]} -xe"
    addEmulator 1 "atari800-5200" "atari5200" "$md_inst/atari800.sh %ROM% ${params[*]} -5200"
    addSystem "atari800"
    addSystem "atari5200"
}
