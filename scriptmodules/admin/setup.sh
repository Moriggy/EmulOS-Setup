#!/usr/bin/env bash

# This file is part of The EmulOS Project
#
# The EmulOS Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/EmulOS/EmulOS-Setup/master/LICENSE.md
#

rp_module_id="setup"
rp_module_desc="GUI based setup for EmulOS"
rp_module_section=""

function _setup_gzip_log() {
    setsid tee >(setsid gzip --stdout >"$1")
}

function rps_logInit() {
    if [[ ! -d "$__logdir" ]]; then
        if mkdir -p "$__logdir"; then
            chown $user:$user "$__logdir"
        else
            fatalError "No se pudo crear el directorio $__logdir"
        fi
    fi
    local now=$(date +'%Y-%m-%d_%H%M%S')
    logfilename="$__logdir/rps_$now.log.gz"
    touch "$logfilename"
    chown $user:$user "$logfilename"
    time_start=$(date +"%s")
}

function rps_logStart() {
    echo -e "Inicio sesion el: $(date -d @$time_start)\n"
    echo "EmulOS-Setup version: $__version ($(git -C "$scriptdir" log -1 --pretty=format:%h))"
    echo "System: $__os_desc - $(uname -a)"
}

function rps_logEnd() {
    time_end=$(date +"%s")
    echo
    echo "El registro termino en: $(date -d @$time_end)"
    date_total=$((time_end-time_start))
    local hours=$((date_total / 60 / 60 % 24))
    local mins=$((date_total / 60 % 60))
    local secs=$((date_total % 60))
    echo "Tiempo de ejecucion: $hours horas, $mins minutos, $secs segundos"
}

function rps_printInfo() {
    reset
    if [[ ${#__ERRMSGS[@]} -gt 0 ]]; then
        printMsgs "dialog" "${__ERRMSGS[@]}"
        printMsgs "dialog" "Consulte $1 para obtener más informacion detallada sobre los errores."
    fi
    if [[ ${#__INFMSGS[@]} -gt 0 ]]; then
        printMsgs "dialog" "${__INFMSGS[@]}"
    fi
    __ERRMSGS=()
    __INFMSGS=()
}

function depends_setup() {
    # check for VERSION file - if it doesn't exist we will run the post_update script as it won't be triggered
    # on first upgrade to 4.x
    if [[ ! -f "$rootdir/VERSION" ]]; then
        joy2keyStop
        exec "$scriptdir/emulos_pkgs.sh" setup post_update gui_setup
    fi

    if isPlatform "rpi" && isPlatform "mesa" && ! isPlatform "rpi4"; then
        printMsgs "dialog" "ERROR: Tiene habilitado el controlador experimental GL de escritorio. Esto NO es compatible con EmulOS, EmulationStation y los emuladores no se ejecutarán.\n\nDeshabilite el controlador experimental GL de escritorio desde el menú 'Opciones avanzadas' de raspi-config."
    fi

    if [[ "$__os_debian_ver" -eq 8 ]]; then
        printMsgs "dialog" "Raspbian/Debian Jessie and versions of Ubuntu below 16.04 are no longer supported.\n\nPlease install EmulOS 4.4 or newer from a fresh image which is based on Raspbian Stretch (or if running Ubuntu, upgrade your OS)."
    fi

    # make sure user has the correct group permissions
    if ! isPlatform "x11"; then
        local group
        for group in input video; do
            if ! hasFlag "$(groups $user)" "$group"; then
                dialog --yesno "Su usuario '$usuario' no es miembro del grupo de sistemas '$group'. \n\n Es necesario para que EmulOS funcione correctamente. ¿Puedo agregar '$usuario' al grupo '$group'?\n\nTendrás que reiniciar para que estos cambios surtan efecto." 22 76 2>&1 >/dev/tty && usermod -a -G "$group" "$user"
            fi
        done
    fi

    # remove all but the last 20 logs
    find "$__logdir" -type f | sort | head -n -20 | xargs -d '\n' --no-run-if-empty rm
}

function updatescript_setup()
{
    clear
    chown -R $user:$user "$scriptdir"
    printHeading "Obteniendo la última versión del script de EmulOS-Setup."
    pushd "$scriptdir" >/dev/null
    if [[ ! -d ".git" ]]; then
        printMsgs "dialog" "No se puede encontrar el directorio '.git'. Por favor, clona el script de configuración de EmulOS a traves de 'git clone https://github.com/Moriggy/EmulOS-Setup.git'"
        popd >/dev/null
        return 1
    fi
    local error
    if ! error=$(su $user -c "git pull 2>&1 >/dev/null"); then
        printMsgs "dialog" "Actualización fallida:\n\n$error"
        popd >/dev/null
        return 1
    fi
    popd >/dev/null

    printMsgs "dialog" "Ya tienes descargada la última versión del script de EmulOS-Setup."

    # Añadido para copiar los archivos del menu opciones
    if [[ -f "/home/pi/EmulOS/emulosmenu/raspiconfig.rp" ]]; then
      cd
      sudo cp /home/pi/EmulOS-Setup/scriptmodules/extras/gamelist.xml /opt/emulos/configs/all/emulationstation/gamelists/emulos/
      sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/supplementary/emulosmenu/* /home/pi/EmulOS/emulosmenu/
    fi
    # FIN DEL AÑADIDO

    return 0
}

function post_update_setup() {
    local return_func=("$@")

    joy2keyStart

    echo "$__version" >"$rootdir/VERSION"

    clear
    local logfilename
    rps_logInit
    {
        rps_logStart
        # run _update_hook_id functions - eg to fix up modules for emulos-setup 4.x install detection
        printHeading "Ejecución de ganchos posteriores a la actualización"
        rp_updateHooks
        rps_logEnd
    } &> >(_setup_gzip_log "$logfilename")
    rps_printInfo "$logfilename"

    printMsgs "dialog" "AVISO: la secuencia de comandos de EmulOS-Setup y las imágenes de la tarjeta SD de EmulOS prefabricadas están disponibles para descargar de forma gratuita desde http://masos.dx.am/ .\n\nLa imagen de EmulOS preconstruida incluye software que tiene licencias no comerciales. No está permitido vender imagenes de EmulOS ni incluir EmulOS con su producto comercial. \n\nNo se incluyen juegos con derechos de autor en EmulOS.\n\nSi le vendieron este software, puede informarnos al respecto enviando un correo electronico a masosgroup@gmail.com ."

    # return to set return function
    "${return_func[@]}"
}

function package_setup() {
    local idx="$1"
    local md_id="${__mod_id[$idx]}"

    # associative array so we can pull out the messages later for the confirmation requester
    declare -A option_msgs=(
        ["U"]=""
        ["B"]="Instalar binario pre-compilado"
        ["S"]="Instalar desde la fuente"
    )

    while true; do
        local options=()

        local status

        local has_binary=0
        rp_hasBinary "$idx"
        local binary_ret="$?"
        [[ "$binary_ret" -eq 0 ]] && has_binary=1

        local pkg_origin=""
        local source_update=0
        local binary_update=0
        if rp_isInstalled "$idx"; then
          eval $(rp_getPackageInfo "$idx")
          status="Instalado - via $pkg_origin"
            [[ -n "$pkg_date" ]] && status+=" (built: $pkg_date)"
            if [[ "$pkg_origin" != "source" && "$has_binary" -eq 1 ]]; then
               rp_hasNewerBinary "$idx"
               local has_newer="$?"
               binary_update=1
               option_msgs["U"]="Actualizar (desde binario pre-construido)"
                case "$has_newer" in
                    0)
                        status+="\nActualizacion binaria disponible."
                        ;;
                    1)
                        status+="\nEstas ejecutando el ultimo binario."
                        option_msgs["U"]="Re-instalar (desde binario pre-construido)"
                        ;;
                    2)
                        status+="\nLa actualizacion binaria puede estar disponible (no se puede verificar este paquete)."
                        ;;
                esac
            fi
            if [[ "$binary_update" -eq 0 && "$binary_ret" -ne 4 ]]; then
                source_update=1
                option_msgs["U"]="Actualizar (desde la fuente)"
            fi
        else
            status="No instalado"
        fi

        # if we had a network error don't display install options
        if [[ "$binary_ret" -eq 4 ]]; then
            status+="\nOpciones de instalación deshabilitadas (No se puede acceder a internet)"
        else
            if [[ "$source_update" -eq 1 || "$binary_update" -eq 1 ]]; then
                options+=(U "${option_msgs["U"]}")
            fi

            if [[ "$binary_update" -eq 0 && "$has_binary" -eq 1 ]]; then
                options+=(B "${option_msgs["B"]}")
            fi

            if [[ "$source_update" -eq 0 ]] && fnExists "sources_${md_id}"; then
                    options+=(S "${option_msgs[S]}")
            fi
        fi

        if rp_isInstalled "$idx"; then
            if fnExists "gui_${md_id}"; then
                options+=(C "Configuración / Opciones")
            fi
            options+=(X "Eliminar")
        fi

        if [[ -d "$__builddir/$md_id" ]]; then
            options+=(Z "Limpiar carpeta de origen")
        fi

        local help="${__mod_desc[$idx]}\n\n${__mod_help[$idx]}"
        if [[ -n "$help" ]]; then
            options+=(H "Paquete de ayuda")
        fi

        cmd=(dialog --backtitle "$__backtitle" --cancel-label "Atrás" --menu "Elige una opción para ${__mod_id[$idx]} \n$status" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        local logfilename

        case "$choice" in
            U|B|S)
                dialog --defaultno --yesno "Estás seguro que quieres ${option_msgs[$choice]}" 22 76 2>&1 >/dev/tty || continue
                local mode
                case "$choice" in
                    U) mode="_auto_" ;;
                    B) mode="_binary_" ;;
                    S) mode="_source_" ;;
                esac
                clear
                rps_logInit
                {
                    rps_logStart
                    rp_installModule "$idx" "$mode" "force"
                    rps_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            C)
                rps_logInit
                {
                    rps_logStart
                    rp_callModule "$idx" gui
                    rps_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            X)
                local text="Estás seguro de que deseas eliminar $md_id?"
                [[ "${__mod_section[$idx]}" == "core" ]] && text+="\n\nADVERTENCIA: ¡se necesitan paquetes del core -nucleo- para que funcione EmulOS!"
                dialog --defaultno --yesno "$text" 22 76 2>&1 >/dev/tty || continue
                rps_logInit
                {
                    rps_logStart
                    rp_callModule "$idx" remove
                    rps_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            H)
                printMsgs "dialog" "$help"
                ;;
            Z)
                rp_callModule "$idx" clean
                printMsgs "dialog" "$__builddir/$md_id ha sido eliminado."
                ;;
            *)
                break
                ;;
        esac

    done
}

function section_gui_setup() {
    local section="$1"

    local default=""
    while true; do
        local options=()
        local pkgs=()

        local idx
        local pkg_origin
        local num_pkgs=0
        for idx in $(rp_getSectionIds $section); do
            if rp_isInstalled "$idx"; then
                installed="(instalado)"
                ((num_pkgs++))
            else
                installed=""
            fi
            pkgs+=("$idx" "${__mod_id[$idx]} $installed" "$idx ${__mod_desc[$idx]}"$'\n\n'"${__mod_help[$idx]}")
        done

        if [[ "$num_pkgs" -gt 0 ]]; then
            options+=(
                U "Actualizar todos los paquetes de ${__sections[$section]} " "Esto actualizará cualquier paquete instalado de ${__sections[$section]} . Los paquetes serán actualizados por el método utilizado previamente."
            )
        fi

        # allow installing an entire section except for drivers - as it's probably a bad idea
        if [[ "$section" != "driver" ]]; then
            options+=(
                I "Instalar todos los paquetes de ${__sections[$section]} " "Esto instalará todos los paquetes de ${__sections[$section]} . Si un paquete no está instalado y hay un binario precompilado disponible, se utilizará. Si un paquete ya está instalado, se actualizará mediante el método utilizado anteriormente"
                X "Eliminar todos los paquetes de ${__sections[$section]} " "X Esto eliminará todos los paquetes de $section ."
            )
        fi

        options+=("${pkgs[@]}")

        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Atrás" --item-help --help-button --default-item "$default" --menu "Elige una opción" 22 76 16)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            # remove HELP
            choice="${choice[@]:5}"
            # get id of menu item
            default="${choice/%\ */}"
            # remove id
            choice="${choice#* }"
            printMsgs "dialog" "$choice"
            continue
        fi

        default="$choice"

        local logfilename
        case "$choice" in
          U|I)
                local mode="update"
                [[ "$choice" == "I" ]] && mode="install"
                dialog --defaultno --yesno "Estás seguro de que quieres instalar todos los paquetes de $section ?" 22 76 2>&1 >/dev/tty || continue
                rps_logInit
                {
                    rps_logStart
                    for idx in $(rp_getSectionIds $section); do
                      # if we are updating, skip packages that are not installed
                      if [[ "$mode" == "update" ]]; then
                          rp_isInstalled "$idx" && rp_installModule "$idx" "_update_" || break
                      else
                          rp_installModule "$idx" "_auto_" || break
                      fi
                    done
                    rps_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            X)
                local text="¿Seguro que quieres eliminar todos los paquetes de $section?"
                [[ "$section" == "core" ]] && text+="\n\nDVERTENCIA - core ¡se necesitan estos paquetes para que EmulOS funcione!"
                dialog --defaultno --yesno "$text" 22 76 2>&1 >/dev/tty || continue
                rps_logInit
                {
                    rps_logStart
                    for idx in $(rp_getSectionIds $section); do
                        rp_isInstalled "$idx" && rp_callModule "$idx" remove
                    done
                    rps_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            *)
                package_setup "$choice"
                ;;
        esac

    done
}

function config_gui_setup() {
    local default
    while true; do
        local options=()
        local idx
        for idx in "${__mod_idx[@]}"; do
            # show all configuration modules and any installed packages with a gui function
            if [[ "${__mod_section[idx]}" == "config" ]] || rp_isInstalled "$idx" && fnExists "gui_${__mod_id[idx]}"; then
                options+=("$idx" "${__mod_id[$idx]}  - ${__mod_desc[$idx]}" "$idx ${__mod_desc[$idx]}")
            fi
        done

        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Atrás" --item-help --help-button --default-item "$default" --menu "Elige una opción:" 22 76 16)

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            choice="${choice[@]:5}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "$choice"
            continue
        fi

        [[ -z "$choice" ]] && break

        default="$choice"

        local logfilename
        rps_logInit
        {
            rps_logStart
            if fnExists "gui_${__mod_id[choice]}"; then
                rp_callModule "$choice" depends
                rp_callModule "$choice" gui
            else
                rp_callModule "$idx" clean
                rp_callModule "$choice"
            fi
            rps_logEnd
        } &> >(_setup_gzip_log "$logfilename")
        rps_printInfo "$logfilename"
    done
}

function update_packages_setup() {
    clear
    local idx
    for idx in ${__mod_idx[@]}; do
        if rp_isInstalled "$idx" && [[ -n "${__mod_section[$idx]}" ]]; then
            rp_installModule "$idx" "_update_" || return 1
        fi
    done
}

function update_packages_gui_setup() {
    local update="$1"
    if [[ "$update" != "update" ]]; then
        dialog --defaultno --yesno "¿Seguro que quieres actualizar los paquetes instalados?" 22 76 2>&1 >/dev/tty || return 1
        updatescript_setup || return 1
        # restart at post_update and then call "update_packages_gui_setup update" afterwards
        joy2keyStop
        exec "$scriptdir/emulos_pkgs.sh" setup post_update update_packages_gui_setup update
    fi

    local update_os=0
    dialog --yesno "¿Desea actualizar los paquetes subyacentes del sistema operativo? (ej. kernel, etc.)?" 22 76 2>&1 >/dev/tty && update_os=1

    clear

    local logfilename
    rps_logInit
    {
        rps_logStart
        [[ "$update_os" -eq 1 ]] && rp_callModule raspbiantools apt_upgrade
        update_packages_setup
        rps_logEnd
    } &> >(_setup_gzip_log "$logfilename")

    rps_printInfo "$logfilename"
    printMsgs "dialog" "Los paquetes instalados se han actualizado."
    gui_setup
}

function basic_install_setup() {
    local idx
    for idx in $(rp_getSectionIds core) $(rp_getSectionIds main); do
        rp_installModule "$idx" || return 1
    done
    return 0
}

function packages_gui_setup() {
    local section
    local default
    local options=()

    for section in core main opt driver exp; do
        options+=($section "Administrar ${__sections[$section]} paquetes" "$section Elige la parte superior instalar/actualizar/configurar paquetes de la ${__sections[$section]}")
    done

    local cmd
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --cancel-label "Atrás" --item-help --help-button --default-item "$default" --menu "Elige una opción:" 22 76 16)

        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            choice="${choice[@]:5}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "$choice"
            continue
        fi
        section_gui_setup "$choice"
        default="$choice"
    done
}

function uninstall_setup()
{
    dialog --defaultno --yesno "¿Seguro que quieres desinstalar EmulOS?" 22 76 2>&1 >/dev/tty || return 0
    dialog --defaultno --yesno "¿Estás REALMENTE seguro de que deseas desinstalar EmulOS?\n\n$rootdir se eliminará, esto incluye archivos de configuración para todos componentes." 22 76 2>&1 >/dev/tty || return 0
    clear
    printHeading "Desinstalando EmulOS"
    for idx in "${__mod_idx[@]}"; do
        rp_isInstalled "$idx" && rp_callModule $idx remove
    done
    rm -rfv "$rootdir"
    dialog --defaultno --yesno "¿Desea eliminar todos los archivos de $datadir ? Esto incluye todas las ROM instaladas, los archivos de la BIOS y los splashscreen." 22 76 2>&1 >/dev/tty && rm -rfv "$datadir"
    if dialog --defaultno --yesno "¿Desea eliminar todos los paquetes de sistema de los que depende EmulOS?\n\nADVERTENCIA: esto eliminará paquetes como SDL incluso si se instalaron antes de instalar EmulOS - también eliminara cualquier configuración de paquete - como los de /etc/ samba para Samba. \n\nSi no esta seguro, elija No (seleccionado por defecto)." 22 76 2>&1 >/dev/tty; then
        clear
        # remove all dependencies
        for idx in "${__mod_idx[@]}"; do
            rp_isInstalled "$idx" && rp_callModule "$idx" depends remove
        done
    fi
    printMsgs "dialog" "EmulOS ha sido desinstalado."
}

function reboot_setup()
{
    clear
    reboot
}

# arranque silencioso de instalación base
function silencio() {
	fichero_nec="/boot/cmdline.txt"
	clear
	cp $fichero_nec $fichero_nec.bkp
	dato="$(cat /boot/cmdline.txt | grep 'PARTUUID' | cut -d  " "  -f4)"

	if [[ -f "$fichero_nec" ]]; then
		sudo cat > $fichero_nec <<_EOF_
dwc_otg.lpm_enable=0 console=serial0,115200 console=tty3 loglevel=3 $dato rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait plymouth.enable=0 logo.nologo
_EOF_
		sudo chmod -R +x $fichero_nec
		sudo chown -R root:root $fichero_nec

	else
		echo "El $fichero no existe, no se ha podido configurar el arranque silencioso." ; sleep 2
	fi

}

# emulos-setup main menu
function gui_setup() {
    depends_setup
    joy2keyStart
    local default
    while true; do
        local commit=$(git -C "$scriptdir" log -1 --pretty=format:"%cr (%h)")

        cmd=(dialog --backtitle "$__backtitle" --title "EmulOS-Setup Script" --cancel-label "Salir" --item-help --help-button --default-item "$default" --menu "Versión: $__version (funcionando en $__os_desc)\nÚltimo Commit: $commit" 22 76 16)
        options=(
        I "EmulOS Instalacion basica" "Esto instalará todos los paquetes de Core y Main, lo que da una instalación basica de EmulOS.\nPosteriormente, se pueden instalar más paquetes desde las secciones Opcional y Experimental. Si hay binarios disponibles, se usarán, o los paquetes se construirán desde la fuente, lo que llevará más tiempo."

        U "Update" "U Actualiza el script EmulOS-Setup y todos los paquetes instalados actualmente. También permitirá actualizar paquetes de sistema operativo. Si hay binarios disponibles, se usarán. De lo contrario, los paquetes se compilarán a partir de la fuente."

        P "Administrar paquetes"
        "P Instalar / Quitar y configurar los diversos componentes de EmulOS, incluidos emuladores, ports y controladores."

        C "Configuración / herramientas"
        "C Configuración y herramientas. Configure samba y cualquier paquete que haya instalado que tenga opciones de configuración adicionales también aparecerán aquí."

        S "Actualizar script EmulOS-Setup"
        "S Actualice el script EmulOS-Setup. Esto actualizará SÓLO este script de administración principal, pero NO actualizará ningún paquete de software. Para actualizar los paquetes, use la opción 'Update' del menú principal, que también actualizará el script de instalación de EmulOS."

        # X "Desinstalar EmulOS"
        # "X Desinstalar completamente EmulOS."

        R "Realice un reinicio"
        "R Reinicia tu dispositivo, reinicie su máquina para que las modificaciones tengan efecto."
        )

        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break

        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            choice="${choice[@]:5}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "$choice"
            continue
        fi
        default="$choice"

        case "$choice" in
            I)
                dialog --defaultno --yesno "¿Estás seguro de que quieres hacer una instalación básica?\n\nEsto instalará todos los paquetes del 'Core' y 'Main'." 22 76 2>&1 >/dev/tty || continue
                clear
                local logfilename
                rps_logInit
                {
                    rps_logStart
                    #sudo apt-get install -y libboost-all-dev
                    basic_install_setup
                    #### gancho nuevo copia de scripts nuestros
              			if [[ -f "/home/pi/EmulOS/emulosmenu/raspiconfig.rp" ]]; then
                      #silencio
                      cd
                      sudo cp /home/pi/EmulOS-Setup/scriptmodules/extras/gamelist.xml /opt/emulos/configs/all/emulationstation/gamelists/emulos/
                			sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/supplementary/emulosmenu/* /home/pi/EmulOS/emulosmenu/
                      sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/extras/shutdown /home/pi/EmulOS/
                      #sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/extras/es_idioma/emulationstation.sh /opt/emulos/supplementary/emulationstation/
                			#sudo cp -R /home/pi/EmulOS-Setup/scriptmodules/extras/es_idioma/* /opt/emulos/supplementary/emulationstation/
      		          fi
                    rps_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            U)
                update_packages_gui_setup
                ;;
            P)
                packages_gui_setup
                ;;
            C)
                config_gui_setup
                ;;
            S)
                dialog --defaultno --yesno "¿Estás seguro que quieres actualizar el script EmulOS-Setup?" 22 76 2>&1 >/dev/tty || continue
                if updatescript_setup; then
                    joy2keyStop
                    exec "$scriptdir/emulos_pkgs.sh" setup post_update gui_setup
                fi
                ;;
            X)
                local logfilename
                rps_logInit
                {
                    uninstall_setup
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            R)
                dialog --defaultno --yesno "¿Estás seguro de que quieres reiniciar?\n\nTen en cuenta que si reinicias cuando se está ejecutando EmulationStation, perderás los cambios en los metadatos." 22 76 2>&1 >/dev/tty || continue
                reboot_setup
                ;;
        esac
    done
    joy2keyStop
    clear
}
