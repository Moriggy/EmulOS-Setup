#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
# Menu de retropie usado en EmulOS....

rp_module_id="emulosmenu"
rp_module_desc="Configuración del menú EmulOS para EmulationStation"
rp_module_section="core"

function _update_hook_emulosmenu() {
    # to show as installed when upgrading to emulos-setup 4.x
    if ! rp_isInstalled "$md_idx" && [[ -f "$home/.emulationstation/gamelists/emulos/gamelist.xml" ]]; then
        mkdir -p "$md_inst"
        # to stop older scripts removing when launching from emulos menu in ES due to not using exec or exiting after running emulos-setup from this module
        touch "$md_inst/.emulos"
    fi
}

function depends_emulosmenu() {
    getDepends mc
}

function install_bin_emulosmenu() {
    return
}

function configure_emulosmenu()
{
    [[ "$md_mode" == "remove" ]] && return

    local rpdir="$home/EmulOS/emulosmenu"
    mkdir -p "$rpdir"
    cp -Rv "$md_data/icons" "$rpdir/"
    chown -R $user:$user "$rpdir"

    isPlatform "rpi" && rm -f "$rpdir/dispmanx.rp"

    # add the gameslist / icons
    local files=(
        'audiosettings'
		    'bluetooth'
        'configedit'
        'emulosextrasall'
        'esthemes'
        'filemanager'
        'personalizaremulos'
        'raspiconfig'
        'retroarch'
        'retronetplay'
        'rpsetup'
        'runcommand'
        'splashscreen'
        'systeminfo'
        'wifi'
    )

    local names=(
        'Audio'
        'Bluetooth'
        'Editar Config'
        'EmulOS Herramientas y utils'
        'ES Themes'
        'Administrador de Archivos'
        'Personalizar EmulOS'
        'Raspi-Config'
        'Retroarch'
        'RetroArch Net Play'
        'EmulOS Setup'
        'Run Command Configuracion'
        'Configurar Splash Screens'
        'Informacion del sistema'
        'WiFi agregar o editar config'
    )

    local descs=(
        'Configuraciones de audio Elija predeterminado de auto, jack de 3.5 mm o HDMI. Controles del mezclador y aplicar configuraciones predeterminadas.'
		    'Regístra y conécta dispositivos bluetooth. Anula el registro y elimina los dispositivos y visualiza los dispositivos registrados y conectados.'
        'Cambie las opciones comunes de RetroArch y edite manualmente las configuraciones de RetroArch, las configuraciones globales y las configuraciones que no son de RetroArch.'
        'Opciones para traducir EmulationStation a español en PC y otras utilidades'
        'Instalar, desinstalar, o actualizar themes de EmulationStation. Muchos themes los puedes ver en nuestra web: http://es-themes-masos.ml'
        'Administrador de archivos básico de ASCII para Linux que le permite navegar, copiar, eliminar y mover archivos. (Es necesario tener teclado conectado)'
        'Podrás añadir bezels, videoloading screen a tus sistemas y hacer Overclock a tu RPI'
        'Cambie la contraseña del usuario, las opciones de arranque, la internacionalización, la cámara, agregue su pi a Rastrack, overclock, overscan, división de memoria, SSH y más.'
        'Inicia la GUI de RetroArch para que pueda cambiar las opciones de RetroArch. Nota: Los cambios no se guardarán a menos que haya habilitado la opción "Guardar configuración al salir".'
        'Configure las opciones de RetroArch Netplay, elija host o cliente, puerto, IP de host, marcos de demora y su apodo.'
        'Instale EmulOS desde binario o fuente, instale paquetes experimentales, controladores adicionales, edite recursos compartidos de samba, raspador personalizado, así como otras configuraciones relacionadas con EmulOS.'
        'Change what appears on the runcommand screen. Enable or disable the menu, enable or disable box art, and change CPU configuration.'
        'Habilite o deshabilite la pantalla secundaria en el inicio de EmulOS. Elija una pantalla secundaria, descargue nuevas pantallas emergentes y regrese la pantalla secundaria a la predeterminada.'
        'Vea información útil de su sistema como dirección IP, temperatura, espacio disponible...'
        'Conéctese o desconecte de una red wifi y configure wifi.'
    )

    setESSystem "EmulOS" "emulos" "$rpdir" ".rp .sh" "sudo $scriptdir/emulos_pkgs.sh emulosmenu launch %ROM% </dev/tty >/dev/tty" "" "emulos"

    local file
    local name
    local desc
    local image
    local i
    for i in "${!files[@]}"; do
        case "${files[i]}" in
            audiosettings|raspiconfig|splashscreen)
                ! isPlatform "rpi" && continue
                ;;
            wifi)
                [[ "$__os_id" != "Raspbian" ]] && continue
        esac

        file="${files[i]}"
        name="${names[i]}"
        desc="${descs[i]}"
        image="$home/EmulOS/emulosmenu/icons/${files[i]}.png"

        touch "$rpdir/$file.rp"

        local function
        for function in $(compgen -A function _add_rom_); do
            "$function" "emulos" "EmulOS" "$file.rp" "$name" "$desc" "$image"
        done
    done
}

function remove_emulosmenu() {
    rm -rf "$home/EmulOS/emulosmenu"
    rm -rf "$home/.emulationstation/gamelists/emulos"
    delSystem emulos
}

function launch_emulosmenu() {
    clear
    local command="$1"
    local basename="${command##*/}"
    local no_ext="${basename%.rp}"
    joy2keyStart
    case "$basename" in
        retroarch.rp)
            joy2keyStop
            cp "$configdir/all/retroarch.cfg" "$configdir/all/retroarch.cfg.bak"
            chown $user:$user "$configdir/all/retroarch.cfg.bak"
            su $user -c "\"$emudir/retroarch/bin/retroarch\" --menu --config \"$configdir/all/retroarch.cfg\""
            iniConfig " = " '"' "$configdir/all/retroarch.cfg"
            iniSet "config_save_on_exit" "false"
            ;;
        rpsetup.rp)
            rp_callModule setup gui
            ;;
        raspiconfig.rp)
            raspi-config
            ;;
        filemanager.rp)
            mc
            ;;
        showip.rp)
            local ip="$(ip route get 8.8.8.8 2>/dev/null | awk '{print $NF; exit}')"
            printMsgs "dialog" "Su IP es: $ip\n\nOutput of 'ip addr show':\n\n$(ip addr show)"
            ;;
        *.rp)
            rp_callModule $no_ext depends
            if fnExists gui_$no_ext; then
                rp_callModule $no_ext gui
            else
                rp_callModule $no_ext configure
            fi
            ;;
        *.sh)
            cd "$home/EmulOS/emulosmenu"
            sudo -u "$user" bash "$command"
            ;;
    esac
    joy2keyStop
    clear
}
