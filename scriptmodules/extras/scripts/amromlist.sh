#!/usr/bin/env bash

#################################################
#                                               #
# Utilidad de autoconfiguracion de Attract Mode #
#                                               #
#################################################

IFS=";"
clear

rm /tmp/showdisplay.txt > /dev/null 2>&1
rm /tmp/hidedisplay.txt > /dev/null 2>&1

function show_display_traditional() {
currentdisplay="${1}"
ischoice="false"
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
while read line
do
if [[ $line == "display"*"${currentdisplay}" ]]; then
  echo $line >> /tmp/temp.cfg
  ischoice="true"
elif [[ $line == "display"* && $line != "displays_menu_exit"* ]]; then
  echo $line >> /tmp/temp.cfg
  ischoice="false"
elif [[ $line == *"in_cycle"* && $ischoice = "true" ]]; then
  echo -e "\tin_cycle             no" >> /tmp/temp.cfg
elif [[ $line == *"in_menu"* && $ischoice = "true" ]]; then
  echo -e "\tin_menu              no" >> /tmp/temp.cfg
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

#########################################################################
# Obtener lista de los sistemas y verificar los archivos ROM existentes #
#########################################################################

ifexist=0
while read sname romdir ext
do
if [[ -d "/home/pi/EmulOS/roms/${romdir}" ]];then
 ext=`echo "$ext" | sed "s/ /|/g"`
 files=`ls /home/pi/EmulOS/roms/${romdir} |egrep ${ext}` 2> /dev/null
 if [[ -z $files ]];then
  ifexist=0
  echo "${sname}" >> /tmp/hidedisplay.txt
 else
  ifexist=1
  echo "${sname}" >> /tmp/showdisplay.txt
 fi
fi
done < /home/pi/.attract/amboot/amromlist.info

###########################################
# Actualice los archivos romlist anidados #
###########################################

while read systemname
do
show_display_nested "${systemname}"
done < /tmp/showdisplay.txt

while read systemname
do
hide_display_nested "${systemname}"
done < /tmp/hidedisplay.txt

###############################################
# Actualizar el menú principal de attract.cfg #
###############################################

cp /home/pi/.attract/attract.cfg /home/pi/.attract/attract.cfg.bkp
cp /home/pi/.attract/attract.cfg /tmp/attract_tmp.cfg

mv /tmp/temp.cfg /tmp/attract_tmp.cfg

cp /tmp/attract_tmp.cfg /home/pi/.attract/attract.cfg

clear
