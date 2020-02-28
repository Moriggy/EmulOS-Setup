#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="openbor-6xxx"
rp_module_desc="OpenBOR - Beat 'em Up Game Engine v6510-dev (OFICIAL!!)"
rp_module_help="Coloca tus juegos .pak en $romdir/openbor y luego ejecutalos desde el sistema Openbor, los juegos comenzarán automáticamente."
rp_module_licence="BSD https://raw.githubusercontent.com/crcerror/OpenBOR-Raspberry/master/LICENSE"
rp_module_section="exp"
rp_module_flags="dispmanx !mali !x11"

function strip() {
    #$1 string name, $2 string length to cut
    # Set string length to -5 to remove last 5 characters
    # So openbor-3400 will be installed to openbor
    echo "${1:0:$2}"
}

function depends_openbor-6xxx() {
    getDepends libsdl2-gfx-dev libvorbisidec-dev libvpx-dev libogg-dev libsdl2-gfx-1.0-0 libvorbisidec1
}

function sources_openbor-6xxx() {
    gitPullOrClone "$md_build" https://github.com/crcerror/OpenBOR-Raspberry.git
}

function build_openbor-6xxx() {
    local params=()
    ! isPlatform "x11" && params+=(BUILD_PANDORA=1)
    make clean-all BUILD_PANDORA=1
    patch -p0 -i ./patch/latest_build.diff
    make "${params[@]}"
    md_ret_require="$md_build/OpenBOR"
    wget -q --show-progress "http://raw.githubusercontent.com/crcerror/OpenBOR-63xx-RetroPie-openbeta/master/libGL-binary/libGL.so.1.gz"
    gunzip -f libGL.so.1.gz
}

function install_openbor-6xxx() {
    md_ret_files=(
       'OpenBOR'
       'libGL.so.1'
    )
}

function configure_openbor-6xxx() {
    md_id="$(strip $md_id -5)"

    addPort "$md_id" "openbor" "OpenBOR - Beats of Rage Engine" "pushd $md_inst; $md_inst/OpenBOR %ROM%; popd"
    addSystem "$md_id"
    mkRomDir "$md_id"
    setDispmanx "$md_id" 1

    cat >"$romdir/$md_id/OpenBOR - Module Selection Script.sh" <<_EOF_
#!/bin/bash
readonly JOY2KEY_SCRIPT="\$HOME/EmulOS-Setup/scriptmodules/helpers.sh"
readonly OPENBOR_ROMDIR="$romdir/$md_id"
[[ -e \$JOY2KEY_SCRIPT ]] || (cd $md_inst; ./OpenBOR; kill \$\$)
sleep 0.5; sudo pkill -f joy2key
source "\$JOY2KEY_SCRIPT"
scriptdir="\$HOME/EmulOS-Setup"
for file in "\$OPENBOR_ROMDIR/"*.[Pp][Aa][Kk]; do
  [[ -e \$file ]] || continue
  filename="\${file##*/}"; filename="\${filename%.*}"
  darray+=("\$file" "\$filename")
done
if [[ \${#darray[@]} -gt 0 ]]; then
    joy2keyStart; sleep 0.2
    cmd=(dialog --backtitle " OpenBOR - The ultimate 2D gaming engine " --title " Module selection list " --no-tags --stdout --menu "Por favor seleccione un juego de la lista para ser lanzado:" 16 75 16)
    choices=\$("\${cmd[@]}" "\${darray[@]}")
    joy2keyStop; sleep 0.2
    [[ \$choices ]] || exit
fi
"/opt/emulos/supplementary/runcommand/runcommand.sh" 0 _PORT_ "openbor" "\$choices"
_EOF_

#Correcting file owner and attributes
chown $(logname):$(logname) "$romdir/$md_id/OpenBOR - Module Selection Script.sh"
chmod +x "$romdir/$md_id/OpenBOR - Module Selection Script.sh"
mv "$romdir/ports/OpenBOR - Beats of Rage Engine.sh" "$romdir/$md_id"

    local dir
    for dir in ScreenShots Saves; do
        mkUserDir "$md_conf_root/$md_id/$dir"
        ln -snf "$md_conf_root/$md_id/$dir" "$md_inst/$dir"
    done

    ln -snf "$romdir/$md_id" "$md_inst/Paks"
    ln -snf "/dev/shm" "$md_inst/Logs"
}
