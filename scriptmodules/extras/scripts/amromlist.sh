#!/usr/bin/env bash

#################################################
#                                               #
# Utilidad de autoconfiguracion de Attract Mode #
#                                               #
#################################################

IFS=";"
clear

user="$(cat /etc/passwd | grep '1000' | cut -d: -f1)"
ruta="/opt/emulos/configs/all/attractmode"
rm -R $ruta/romlists/*.txt

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

function show_display() {
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
else
  echo -e "${line}" >> /tmp/temp.cfg
fi
done < /tmp/attract_tmp.cfg
rm /tmp/attract_tmp.cfg
mv /tmp/temp.cfg /tmp/attract_tmp.cfg
}

function hide_display() {
currentdisplay="${1}"
ischoice="false"

while read line
do
  if [[ $line == "display"*"${currentdisplay}" ]]; then
    echo $line >> /tmp/temp.cfg
    ischoice="false"
  elif [[ $line == "display"* && $line != "displays_menu_exit"* ]]; then
    echo $line >> /tmp/temp.cfg
    ischoice="false"
  elif [[ $line == *"in_cycle"* && $ischoice = "false" ]]; then
    echo -e "\tin_cycle             no" >> /tmp/temp.cfg
  elif [[ $line == *"in_menu"* && $ischoice = "false" ]]; then
    echo -e "\tin_menu              no" >> /tmp/temp.cfg
  else
    echo -e "${line}" >> /tmp/temp.cfg
  fi
done < /tmp/attract_tmp.cfg
rm /tmp/attract_tmp.cfg
mv /tmp/temp.cfg /tmp/attract_tmp.cfg
}

############################################################################
# llamada a la funcion para ocultar pantalla de sistema que no tiene juegos

let i=0 # definir contador
W=() # definir array
while read -r line; do # leemos linea a linea el txt
    let i=$i+1
    W+=($i "$line")
    hide_display $line
done < <(cat /tmp/hidedisplay.txt)

#################################################################################################
# llamada a la funcion para mostrar pantalla de sistema que tiene juegos y crear lista de juegos

let o=0
R=()
while read -r lines; do
  let o=$o+1
  R+=($o "$lines")
  show_display $lines
  sudo -u $user attract --build-romlist "$lines" -o "$lines"
done < <(cat /tmp/showdisplay.txt)

##########################################
# actualizar Meny Display de Attract Mode

cp /tmp/attract_tmp.cfg $ruta/attract.cfg
rm /tmp/attract_tmp.cfg
rm /tmp/showdisplay.txt
rm /tmp/hidedisplay.txt

clear
