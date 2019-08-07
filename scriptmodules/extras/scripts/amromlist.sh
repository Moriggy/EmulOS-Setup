#!/usr/bin/env bash

#################################################
#                                               #
# Utilidad de autoconfiguracion de Attract Mode #
#                                               #
#################################################

IFS=";"
#clear
attract_dir="/opt/emulos/configs/all/attractmode"
#################################################
# Si hay roms en el sistema, muestralo en la wheel

config="$attract_dir/attract.cfg"
tab=$'\t'
if [[ -f "$config" ]] && ! grep -q "display$tab$fullname" "$config"; then
    cp "$config" "$config.bak"
    if [[ "$fullname" == "EmulOS" ]]; then
    cat >>"$config" <<_EOF_
display${tab}$fullname
${tab}layout               robo
${tab}romlist              $fullname
_EOF_
  else
    if [ "$(ls $path)" ]; then
    cat >>"$config" <<_EOF_
display${tab}$fullname
${tab}layout               robospin_v4
${tab}romlist              $fullname
${tab}in_cycle             yes
${tab}in_menu              yes
_EOF_
    else
    cat >>"$config" <<_EOF_
display${tab}$fullname
${tab}layout               robospin_v4
${tab}romlist              $fullname
${tab}in_cycle             no
${tab}in_menu              no
_EOF_
    fi
  fi
    chown $user:$user "$config"
fi

#################################################
# Si hay roms en el sistema, crea listado

[[ ! -d "$attract_dir" ]] && return 0

system_name="$1"
system_fullname="$2"
path="$3"
name="$4"
desc="$5"
image="$6"

configs="$attract_dir/romlists/$system_fullname.txt"

# remove extension
path="${path/%.*}"

if [[ ! -f "$configs" ]]; then
    echo "#Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons" >"$config"
fi

# if the entry already exists, remove it
if grep -q "^$path;" "$configs"; then
    sed -i "/^$path/d" "$configs"
fi

echo "$path;$name;$system_fullname;;;;;;;;;;;;;;" >>"$configs"
chown $user:$user "$configs"

#clear
