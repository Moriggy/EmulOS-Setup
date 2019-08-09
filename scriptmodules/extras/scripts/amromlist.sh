#!/usr/bin/env bash

#################################################
#                                               #
# Utilidad de autoconfiguracion de Attract Mode #
#                                               #
#################################################

IFS=";"
#clear
user="$(cat /etc/passwd | grep '1000' | cut -d: -f1)"
ruta="/opt/emulos/configs/all/attractmode"

#########################################################
# Comprobar que sistemas tienen ROMS
#

ifexist=0
while read sname romdir ext
do
if [[ -d "/home/$user/EmulOS/roms/${romdir}" ]];then
 ext=`echo "$ext" | sed "s/ /|/g"`
 files=`ls /home/$user/EmulOS/roms/${romdir} |egrep ${ext}` 2> /dev/null
 if [[ -z $files ]];then
  ifexist=0
  echo "${sname}" >> /tmp/hidedisplay.txt
 else
  ifexist=1
  echo "${sname}" >> /tmp/showdisplay.txt
 fi
fi
done < $ruta/amboot/amromlist.info

################################################
# Actualizar menú principal en attract.cfg

cp $ruta/attract.cfg $ruta/attract.cfg.bkp
cp $ruta/attract.cfg /tmp/attract_tmp.cfg

function show_display_traditional() {
currentdisplay="${1}"
ischoice="false"
let i=0 # define counting variable
W=() # define working array
while read -r line; do # process file by file
    let i=$i+1
    W+=($i "$line")
done < <(cat /tmp/showdisplay.txt)
while read line
do
if [[ $line == "display"*"${currentdisplay}" ]]; then
  echo $line >> /tmp/temp.cfg
  ischoice="true"
elif [[ $line == "display"* && $line != "displays_menu_exit"* ]]; then
  echo $line >> /tmp/temp.cfg
  ischoice="false"
elif [[ $line == *"in_cycle"* && $ischoice = "true" ]]; then
  echo -e "\tin_cycle             yes" >> /tmp/temp.cfg
elif [[ $line == *"in_menu"* && $ischoice = "true" ]]; then
  echo -e "\tin_menu              yes" >> /tmp/temp.cfg
  ischoice="false"
elif [[ $line == "rule"* ]]; then
  echo -e "${line}" >> /tmp/temp.cfg
elif [[ $line == "sound" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "input_map" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "general" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "saver_config" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "layout_config"* ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "intro_config" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "#"* ]]; then
  echo $line >> /tmp/temp.cfg
else
  echo -e "${line}" >> /tmp/temp.cfg
fi
done < /tmp/attract_tmp.cfg
}

function hide_display_traditional() {
currentdisplay="${1}"
ischoice="false"
let i=0 # define counting variable
W=() # define working array
while read -r line; do # process file by file
    let i=$i+1
    W+=($i "$line")
done < <(cat /tmp/hidedisplay.txt)

while read line
do
  if [[ $line == "display"*"EmulOS" || $line == "display"*"Favorites" ]]; then
    echo $line >> /tmp/temp.cfg
    ischoice="true"
elif [[ $line == "display"* && $line != "displays_menu_exit"* ]]; then
  echo $line >> /tmp/temp.cfg
  ischoice="false"
elif [[ $line == *"in_cycle"* && $ischoice = "true" ]]; then
  echo -e "\tin_cycle             yes" >> /tmp/temp.cfg
elif [[ $line == *"in_menu"* && $ischoice = "true" ]]; then
  echo -e "\tin_menu              yes" >> /tmp/temp.cfg
  ischoice="false"
elif [[ $line == *"in_cycle"* && $ischoice = "false" ]]; then
  echo -e "\tin_cycle             no" >> /tmp/temp.cfg
elif [[ $line == *"in_menu"* && $ischoice = "false" ]]; then
  echo -e "\tin_menu              no" >> /tmp/temp.cfg
elif [[ $line == "rule"* ]]; then
  echo -e "${line}" >> /tmp/temp.cfg
elif [[ $line == "sound" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "input_map" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "general" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "saver_config" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "layout_config"* ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "intro_config" ]]; then
  echo $line >> /tmp/temp.cfg
elif [[ $line == "#"* ]]; then
  echo $line >> /tmp/temp.cfg
else
  echo -e "${line}" >> /tmp/temp.cfg
fi
done < /tmp/attract_tmp.cfg
}

#show_display_traditional
hide_display_traditional
#rm /tmp/attract_tmp.cfg
#cp /tmp/temp.cfg $ruta/attract.cfg
#clear
