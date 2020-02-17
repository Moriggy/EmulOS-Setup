#!/usr/bin/env bash

# This file is part of The MasOS Team Project
#
# The EmulOS Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="splashscreen"
rp_module_desc="Configurar Splashscreen"
rp_module_section="main"
rp_module_flags="noinstclean !x86 !osmc !xbian !mali"

rp_module_section="main"
rp_module_flags="noinstclean !x86 !osmc !xbian !mali"

function _update_hook_splashscreen() {
    # make sure splashscreen is always up to date if updating just RetroPie-Setup
    if rp_isInstalled "$md_idx"; then
        install_bin_splashscreen
        configure_splashscreen
    fi
}

function _image_exts_splashscreen() {
    echo '\.bmp\|\.jpg\|\.jpeg\|\.gif\|\.png\|\.ppm\|\.tiff\|\.webp'
}

function _video_exts_splashscreen() {
    echo '\.avi\|\.mov\|\.mp4\|\.mkv\|\.3gp\|\.mpg\|\.mp3\|\.wav\|\.m4a\|\.aac\|\.ogg\|\.flac'
}

function depends_splashscreen() {
    getDepends omxplayer insserv
}

function install_bin_splashscreen() {
    cat > "/etc/systemd/system/asplashscreen.service" << _EOF_
[Unit]
Description=Show custom splashscreen
DefaultDependencies=no
After=console-setup.service
Wants=console-setup.service
ConditionPathExists=$md_inst/asplashscreen.sh
[Service]
Type=oneshot
ExecStart=$md_inst/asplashscreen.sh
RemainAfterExit=yes
[Install]
WantedBy=sysinit.target
_EOF_

    rp_installModule "omxiv"
    gitPullOrClone "$md_inst" https://github.com/Moriggy/emulos-splashscreens.git

    cp "$md_data/asplashscreen.sh" "$md_inst"

    iniConfig "=" '"' "$md_inst/asplashscreen.sh"
    iniSet "ROOTDIR" "$rootdir"
    iniSet "DATADIR" "$datadir"
    iniSet "REGEX_IMAGE" "$(_image_exts_splashscreen)"
    iniSet "REGEX_VIDEO" "$(_video_exts_splashscreen)"

    mkUserDir "$datadir/splashscreens"
    echo "Place your own splashscreens in here." >"$datadir/splashscreens/README.txt"
    chown $user:$user "$datadir/splashscreens/README.txt"
}

function enable_plymouth_splashscreen() {
    local config="/boot/cmdline.txt"
    if [[ -f "$config" ]]; then
        sed -i "s/ *plymouth.enable=0//" "$config"
    fi
}

function disable_plymouth_splashscreen() {
    local config="/boot/cmdline.txt"
    if [[ -f "$config" ]] && ! grep -q "plymouth.enable" "$config"; then
        sed -i '1 s/ *$/ plymouth.enable=0/' "$config"
    fi
}

function default_splashscreen() {
    echo "$md_inst/retropie-default.png" >/etc/splashscreen.list
}

function enable_splashscreen() {
    systemctl enable asplashscreen
}

function disable_splashscreen() {
    systemctl disable asplashscreen
}


function configure_splashscreen() {
    [[ "$md_mode" == "remove" ]] && return

    # remove legacy service
    [[ -f "/etc/init.d/asplashscreen" ]] && insserv -r asplashscreen && rm -f /etc/init.d/asplashscreen

    disable_plymouth_splashscreen
    enable_splashscreen
    [[ ! -f /etc/splashscreen.list ]] && default_splashscreen
}

function remove_splashscreen() {
    enable_plymouth_splashscreen
    disable_splashscreen
    rp_callModule "omxiv" remove
    rm -f /etc/splashscreen.list /etc/systemd/system/asplashscreen.service
    systemctl daemon-reload
}

function choose_path_splashscreen() {
    local options=(
        1 "EmulOS splashscreens"
        2 "Own/Extra splashscreens (from $datadir/splashscreens)"
    )
    local cmd=(dialog --backtitle "$__backtitle" --menu "Escoge una opción." 22 86 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ "$choice" -eq 1 ]] && echo "$md_inst"
    [[ "$choice" -eq 2 ]] && echo "$datadir/splashscreens"
}

function set_append_splashscreen() {
    local mode="$1"
    [[ -z "$mode" ]] && mode="set"
    local path
    local file
    while true; do
        path="$(choose_path_splashscreen)"
        [[ -z "$path" ]] && break
        file=$(choose_splashscreen "$path")
        if [[ -n "$file" ]]; then
            if [[ "$mode" == "set" ]]; then
                echo "$file" >/etc/splashscreen.list
                printMsgs "dialog" "Splashscreen configurado en '$file'"
                break
            fi
            if [[ "$mode" == "append" ]]; then
                echo "$file" >>/etc/splashscreen.list
                printMsgs "dialog" "Splashscreen '$file' añadido a /etc/splashscreen.list"
            fi
        fi
    done
}

function choose_splashscreen() {
    local path="$1"
    local type="$2"

    local regex
    [[ "$type" == "image" ]] && regex=$(_image_exts_splashscreen)
    [[ "$type" == "video" ]] && regex=$(_video_exts_splashscreen)

    local options=()
    local i=0
    while read splashdir; do
        splashdir=${splashdir/$path\//}
        if echo "$splashdir" | grep -q "$regex"; then
            options+=("$i" "$splashdir")
            ((i++))
        fi
    done < <(find "$path" -type f ! -regex ".*/\..*" ! -regex ".*LICENSE" ! -regex ".*README.*" ! -regex ".*\.sh" | sort)
    if [[ "${#options[@]}" -eq 0 ]]; then
        printMsgs "dialog" "No hay splashscreens instalados en $path"
        return
    fi
    local cmd=(dialog --backtitle "$__backtitle" --menu "Elige splashscreen." 22 76 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -n "$choice" ]] && echo "$path/${options[choice*2+1]}"
}


function randomize_splashscreen() {
    options=(
        1 "Random de EmulOS splashscreens"
        2 "Random de nuestros splashscreens (from $datadir/splashscreens)"
        3 "Random de todos los splashscreens"
        4 "Random /etc/splashscreen.list"
    )
    local cmd=(dialog --backtitle "$__backtitle" --menu "Escoge una opción." 22 86 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    iniConfig "=" '"' "$md_inst/asplashscreen.sh"
    case "$choice" in
        1)
            iniSet "RANDOMIZE" "emulos"
            printMsgs "dialog" "Splashscreen random habilitado en el directorio $path"
            ;;
        2)
            iniSet "RANDOMIZE" "custom"
            printMsgs "dialog" "Splashscreen random habilitado en el directorio $path"
            ;;
        3)
            iniSet "RANDOMIZE" "all"
            printMsgs "dialog" "Splashscreen random habilitado para ambos directorios de splashscreen."
            ;;
        4)
            iniSet "RANDOMIZE" "list"
            printMsgs "dialog" "Splashscreen random habilitado para entradas en /etc/splashscreen.list"
            ;;
    esac
}

function preview_splashscreen() {
    local options=(
        1 "Ver splashscreen"
        2 "Ver la presentación de todos los splashscreens"
        3 "Reproducir video splash"
    )

    local path
    local file
    local omxiv="/opt/retropie/supplementary/omxiv/omxiv"
    while true; do
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option." 22 86 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        path="$(choose_path_splashscreen)"
        [[ -z "$path" ]] && break
        while true; do
            case "$choice" in
                1)
                    file=$(choose_splashscreen "$path" "image")
                    [[ -z "$file" ]] && break
                    $omxiv -b "$file"
                    ;;
                2)
                    file=$(mktemp)
                    find "$path" -type f ! -regex ".*/\..*" ! -regex ".*LICENSE" ! -regex ".*README.*" ! -regex ".*\.sh" | sort > "$file"
                    if [[ -s "$file" ]]; then
                        $omxiv -t 6 -T blend -b --once -f "$file"
                    else
                        printMsgs "dialog" "No hay splashscreens instalados en $path"
                    fi
                    rm -f "$file"
                    break
                    ;;
                3)
                    file=$(choose_splashscreen "$path" "video")
                    [[ -z "$file" ]] && break
                    omxplayer --no-osd -b --layer 10000 "$file"
                    ;;
            esac
        done
    done
}

function download_extra_splashscreen() {
    gitPullOrClone "$datadir/splashscreens/emulos-extra" https://github.com/DOCK-PI3/masos-splashscreens-extra
    chown -R $user:$user "$datadir/splashscreens/emulos-extra"
}

function gui_splashscreen() {
    if [[ ! -d "$md_inst" ]]; then
        rp_callModule splashscreen depends
        rp_callModule splashscreen install
    fi
    local cmd=(dialog --backtitle "$__backtitle" --menu "Escoge una opción." 22 86 16)
    while true; do
        local enabled=0
        local random=0
        [[ -n "$(find "/etc/systemd/system/"*".wants" -type l -name "asplashscreen.service")" ]] && enabled=1
        local options=(1 "Escoge splashscreen")
        if [[ "$enabled" -eq 1 ]]; then
            options+=(2 "Deshabilitar splashscreen en el arranque (Habilitado)")
            iniConfig "=" '"' "$md_inst/asplashscreen.sh"
            iniGet "RANDOMIZE"
            random=1
            [[ "$ini_value" == "disabled" ]] && random=0
            if [[ "$random" -eq 1 ]]; then
                options+=(3 "Deshabilitar el random de splashscreens (Habilitado)")
            else
                options+=(3 "Habilitar el random de splashscreen (Deshabilitado)")
            fi
        else
            options+=(2 "Activar splashscreen en el arranque (Disabled)")
        fi
        options+=(
            4 "Usar la pantalla de inicio de EmulOS por defecto"
            5 "Editar manualmente la lista de splashscreen"
            6 "Añadir splashscreen a la lista (para entradas múltiples)"
            7 "Vista previa de splashscreens"
            8 "Actualizar EmulOS splashscreens"
            9 "Descargar EmulOS-Extra splashscreens"
        )
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    set_append_splashscreen set
                    ;;
                2)
                    if [[ "$enabled" -eq 1 ]]; then
                        disable_splashscreen
                        printMsgs "dialog" "Deshabilitado splashscreen en el arranque."
                    else
                        [[ ! -f /etc/splashscreen.list ]] && rp_callModule splashscreen default
                        enable_splashscreen
                        printMsgs "dialog" "Habilitado splashscreen en el arranque."
                    fi
                    ;;
                3)
                    if [[ "$random" -eq 1 ]]; then
                        iniSet "RANDOMIZE" "disabled"
                        printMsgs "dialog" "Deshabilitado random Splashscreen."
                    else
                        randomize_splashscreen
                    fi
                    ;;
                4)
                    default_splashscreen
                    printMsgs "dialog" "Splashscreen configurado en EmulOS por defecto."
                    ;;
                5)
                    editFile /etc/splashscreen.list
                    ;;
                6)
                    set_append_splashscreen append
                    ;;
                7)
                    preview_splashscreen
                    ;;
                8)
                    rp_callModule splashscreen install
                    ;;
                9)
                    rp_callModule splashscreen download_extra
                    printMsgs "dialog" "Los splashscreens de EmulOS-Extra se han descargado en $datadir/splashscreens/emulos-extra"
                    ;;
            esac
        else
            break
        fi
    done
}
