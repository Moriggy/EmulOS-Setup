#!/usr/bin/env bash

# Este fichero es parte del Proyecto MasOS Team
#
# The EmulOS Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/Moriggy/EmulOS-Setup/master/LICENSE.md
#

rp_module_id="systeminfo"
rp_module_desc="Información útil del sistema"
rp_module_section="config"

function gui_systeminfo (){
  source $scriptdir/scriptmodules/supplementary/extrasemulosmenu/systeminfo.sh
}