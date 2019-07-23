#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="kat5200"
rp_module_desc="Emulaodr de Atari 5200/8-bit"
rp_module_help="ROM Extensions: .7z .a52 .bin .zip .7Z .A52 .BIN .ZIP\n\nCopia tus juegos de kat5200 en $romdir/kat5200\n\nCopia tus roms de Atari 5200 en $romdir/atari5200 Necesitas copiar las BIOS de Atari 800/5200 (5200.ROM, ATARIBAS.ROM, ATARIOSB.ROM y ATARIXL.ROM) en $biosdir y en el primer arranque del emulador configurarlo para que escanee dicho directorio para las roms(F1 -> Emulator Configuration -> System Rom Settings)"
rp_module_licence="GPL http://kat5200.jillybunch.com/doc/index.html"
rp_module_section="exp"
rp_module_flags="!mali !kms"

function depends_kat5200() {
    getDepends libsqlite3-dev zlib1g zlib1g-dev libsdl2-dev libsdl2-image-dev libguichan-dev
}

function sources_kat5200() {
    wget -N -q -O- "http://kat5200.jillybunch.com/downloads/kat5200-0.8.1.tar.gz" | tar -xvz --strip-components=1
    # Disable F1 key debugger
    sed -i -e '250d' src/interface/ui.c
    # Allow Select and Start together to quit the program.
    # Update: v0.8.0. supports combo key's this is no longer needed.
    # sed -i '1727 a\
    #     if ((SDL_JoystickGetButton(g_pc_joy[0].joy_ptr,8) == SDL_PRESSED) && (SDL_JoystickGetButton(g_pc_joy[0].joy_ptr,9) == SDL_PRESSED)) return -1;' src/interface/sdl_if.c
}

function build_kat5200() {
    ./configure --prefix="$md_inst"
    make clean
    # Author forgot to include the kat5200.html documentation in the latest version so we'll fake it.
    mkdir doc/kat5200.html/
    touch doc/kat5200.html/deleteme.html
    make
    md_ret_require="$md_build/src/kat5200"
}

function install_kat5200() {
    make install
}

function configure_kat5200() {
    mkRomDir "atari5200"
    mkUserDir "$home/.kat5200"
    mv "/etc/kat5200/kat5200.db3" "$home/.kat5200/"
    chown $user:$user "$home/.kat5200/kat5200.db3"
    moveConfigDir "$home/.kat5200" "$md_conf_root/kat5200"

    addEmulator 1 "kat5200" "atari5200" "$md_inst/bin/kat5200 %ROM%"
    addSystem "atari5200"
}
