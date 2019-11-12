#!/usr/bin/env bash

# This file is part of The EmulOS Project
#
# The EmulOS Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/EmulOS/EmulOS-Setup/master/LICENSE.md
#

rp_module_id="bashwelcometweak"
rp_module_desc="Bash Welcome Tweak (muestra información adicional del sistema al loguear)"
rp_module_section="main"

function install_bashwelcometweak() {
    remove_bashwelcometweak
    cat >> "$home/.bashrc" <<\_EOF_
# EMULOS PROFILE START

function getIPAddress() {
    local ip_route
    ip_route=$(ip -4 route get 8.8.8.8 2>/dev/null)
    if [[ -z "$ip_route" ]]; then
        ip_route=$(ip -6 route get 2001:4860:4860::8888 2>/dev/null)
    fi
    [[ -n "$ip_route" ]] && grep -oP "src \K[^\s]+" <<< "$ip_route"
}

function emulos_welcome() {
    local upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
    local secs=$((upSeconds%60))
    local mins=$((upSeconds/60%60))
    local hours=$((upSeconds/3600%24))
    local days=$((upSeconds/86400))
    local UPTIME=$(printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs")

    # calculate rough CPU and GPU temperatures:
    local cpuTempC
    local cpuTempF
    local gpuTempC
    local gpuTempF
    if [[ -f "/sys/class/thermal/thermal_zone0/temp" ]]; then
        cpuTempC=$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000)) && cpuTempF=$((cpuTempC*9/5+32))
    fi

    if [[ -f "/opt/vc/bin/vcgencmd" ]]; then
        if gpuTempC=$(/opt/vc/bin/vcgencmd measure_temp); then
            gpuTempC=${gpuTempC:5:2}
            gpuTempF=$((gpuTempC*9/5+32))
        else
            gpuTempC=""
        fi
    fi

    local df_out=()
    local line
    while read line; do
        df_out+=("$line")
    done < <(df -h /)

    local rst="$(tput sgr0)"
    local fgblk="${rst}$(tput setaf 0)" # Black - Regular
    local fgred="${rst}$(tput setaf 1)" # Red
    local fggrn="${rst}$(tput setaf 2)" # Green
    local fgylw="${rst}$(tput setaf 3)" # Yellow
    local fgblu="${rst}$(tput setaf 4)" # Blue
    local fgpur="${rst}$(tput setaf 5)" # Purple
    local fgcyn="${rst}$(tput setaf 6)" # Cyan
    local fgwht="${rst}$(tput setaf 7)" # White

    local bld="$(tput bold)"
    local bfgblk="${bld}$(tput setaf 0)"
    local bfgred="${bld}$(tput setaf 1)"
    local bfggrn="${bld}$(tput setaf 2)"
    local bfgylw="${bld}$(tput setaf 3)"
    local bfgblu="${bld}$(tput setaf 4)"
    local bfgpur="${bld}$(tput setaf 5)"
    local bfgcyn="${bld}$(tput setaf 6)"
    local bfgwht="${bld}$(tput setaf 7)"

    local logo=(
        "${fgred}****************************************************"
        "${fgred}**                                                **"
        "${fgred}**   ${bfgwht}******                  **    ****   ****    ${fgred}**"
		    "${fgred}**   ${bfgwht}**                      **   **  ** **   *   ${fgred}**"
        "${fgred}**   ${bfgwht}**                      **   **  ** **       ${fgred}**"
        "${fgred}**   ${bfgwht}******   ** **   **  ** **   **  **  ****    ${fgred}**"
        "${fgred}**   ${bfgwht}**     **  *  ** **  ** **   **  **     **   ${fgred}**"
        "${fgred}**   ${bfgwht}**     **     ** **  ** **   **  ** *   **   ${fgred}**"
        "${fgred}**   ${bfgwht}****** **     **  ****   ***  ****   ****    ${fgred}**"
        "${fgred}**                                                **"
        "${fgred}****************************************************"
        )

    local out
    local i
    for i in "${!logo[@]}"; do
        out+="  ${logo[$i]}  "
        case "$i" in
            0)
                out+="${fggrn}$(date +"%A, %e %B %Y, %X")"
                ;;
            1)
                out+="${fggrn}$(uname -srmo)"
                ;;
            3)
                out+="${fgylw}${df_out[0]}"
                ;;
            4)
                out+="${fgwht}${df_out[1]}"
                ;;
            5)
                out+="${bfgred}Tiempo de actividad.: ${UPTIME}"
                ;;
            6)
                out+="${bfgred}Memoria.............: $(grep MemFree /proc/meminfo | awk {'print $2'})kB (Free) / $(grep MemTotal /proc/meminfo | awk {'print $2'})kB (Total)"
                ;;
            7)
                out+="${bfgred}Procesos Corriendo..: $(ps ax | wc -l | tr -d " ")"
                ;;
            8)
                out+="${bfgred}Dirección IP........: $(getIPAddress)"
                ;;
            9)
                out+="${bfgred}Temperatura.........: CPU: $cpuTempC°C/$cpuTempF°F GPU: $gpuTempC°C/$gpuTempF°F"
                ;;
            10)
                out+="${fgwht}Proyecto EmulOS Team, http://masos.dx.am"
                ;;
        esac
        out+="\n"
    done
    echo -e "\n$out"
}

emulos_welcome
# EMULOS PROFILE END
_EOF_


}

function remove_bashwelcometweak() {
    sed -i '/EMULOS PROFILE START/,/EMULOS PROFILE END/d' "$home/.bashrc"
}

function gui_bashwelcometweak() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Bash Welcome Tweak Configuration" 22 86 16)
    local options=(
        1 "Instalar Bash Welcome Tweak"
        2 "Desinstalar Bash Welcome Tweak"
    )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
                rp_callModule bashwelcometweak install
                printMsgs "dialog" "Instalado el Bash Welcome Tweak."
                ;;
            2)
                rp_callModule bashwelcometweak remove
                printMsgs "dialog" "Eliminado el Bash Welcome Tweak."
                ;;
        esac
    fi
}
