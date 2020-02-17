#!/usr/bin/env bash

# This file is part of The EmulOS Project
#
# The EmulOS Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="bluetooth"
rp_module_desc="Configurar Dispositivos Bluetooth"
rp_module_section="config"

function _update_hook_bluetooth() {
    # fix config location
    [[ -f "$configdir/bluetooth.cfg" ]] && mv "$configdir/bluetooth.cfg" "$configdir/all/bluetooth.cfg"
}

function _get_connect_mode() {
    # get bluetooth config
    iniConfig "=" '"' "$configdir/all/bluetooth.cfg"
    iniGet "connect_mode"
    if [[ -n "$ini_value" ]]; then
        echo "$ini_value"
    else
        echo "default"
    fi
}

function depends_bluetooth() {
    local depends=(bluetooth python-dbus python-gobject)
    if [[ "$__os_id" == "Raspbian" ]]; then
        depends+=(pi-bluetooth raspberrypi-sys-mods)
    fi
    getDepends "${depends[@]}"
}

function get_script_bluetooth() {
    name="$1"
    if ! which "$name"; then
        [[ "$name" == "bluez-test-input" ]] && name="bluez-test-device"
        name="$md_data/$name"
    fi
    echo "$name"
}

function _slowecho_bluetooth() {
    local line

    IFS=$'\n'
    for line in $(echo -e "${1}"); do
        echo -e "$line"
        sleep 1
    done
    unset IFS
}

function bluez_cmd_bluetooth() {
    # create a named pipe & fd for input for bluetoothctl
    local fifo="$(mktemp -u)"
    mkfifo "$fifo"
    exec 3<>"$fifo"
    local line
    while true; do
        _slowecho_bluetooth "$1" >&3
        # collect output for specified amount of time, then echo it
        while read -r line; do
            printf '%s\n' "$line"
            # (slow) reply to any optional challenges
            if [[ -n "$3" && "$line" =~ $3 ]]; then
                _slowecho_bluetooth "$4" >&3
            fi
        done
        _slowecho_bluetooth "quit\n" >&3
        break
    # read from bluetoothctl buffered line by line
    done < <(timeout "$2" stdbuf -oL bluetoothctl --agent=NoInputNoOutput <&3)
    exec 3>&-
}

function list_available_bluetooth() {
    local mac_address
    local device_name
    local info_text="\n\nBuscando..."

    declare -A registered=()
    declare -A found=()

    # get an asc array of registered mac addresses
    while read mac_address; read device_name; do
        registered+=(["$mac_address"]="$device_name")
    done < <(list_registered_bluetooth)

    # sixaxis: add USB pairing information
    [[ -n "$(lsmod | grep hid_sony)" ]] && info_text="Searching ...\n\nRegistro DualShock: mientras este texto esté visible, desenchufe el mando, presiona el botón PS/SHARE y luego vuelve a enchufar el mando."

    dialog --backtitle "$__backtitle" --infobox "$info_text" 7 60 >/dev/tty
    if hasPackage bluez 5; then
        # sixaxis: reply to authorization challenge on USB cable connect
        while read mac_address; read device_name; do
            found+=(["$mac_address"]="$device_name")
       done < <(bluez_cmd_bluetooth "default-agent\nscan on" "15" "Authorize service$" "yes" >/dev/null; bluez_cmd_bluetooth "devices" "3" | grep "^Device " | cut -d" " -f2,3- | sed 's/ /\n/')
    else
      while read; read mac_address; read device_name; do
          found+=(["$mac_address"]="$device_name")
      done < <(hcitool scan --flush | tail -n +2 | sed 's/\t/\n/g')
    fi

        # display any found addresses that are not already registered
        for mac_address in "${!found[@]}"; do
            if [[ -z "${registered[$mac_address]}" ]]; then
                echo "$mac_address"
                echo "${found[$mac_address]}"
            fi
        done
}

function list_registered_bluetooth() {
    local line
    local mac_address
    local device_name
    while read line; do
        mac_address="$(echo "$line" | sed 's/ /,/g' | cut -d, -f1)"
        device_name="$(echo "$line" | sed 's/'"$mac_address"' //g')"
        echo -e "$mac_address\n$device_name"
    done < <($(get_script_bluetooth bluez-test-device) list)
}

function display_active_and_registered_bluetooth() {
    local registered
    local active

    registered="$($(get_script_bluetooth bluez-test-device) list 2>&1)"
    [[ -z "$registered" ]] && registered="No hay dispositivos registrados."

    if [[ "$(hcitool con)" != "Connections:" ]]; then
        active="$(hcitool con 2>&1 | sed 1d)"
    else
        active="There are no active connections"
    fi

    printMsgs "dialog" "Dispositivos Registrados:\n\n$registered\n\n\nConexiones activas:\n\n$active"
}

function remove_device_bluetooth() {
    declare -A mac_addresses=()
    local mac_address
    local device_name
    local options=()
    while read mac_address; read device_name; do
        mac_addresses+=(["$mac_address"]="$device_name")
        options+=("$mac_address" "$device_name")
    done < <(list_registered_bluetooth)

    if [[ ${#mac_addresses[@]} -eq 0 ]] ; then
        printMsgs "dialog" "There are no devices to remove."
    else
        local cmd=(dialog --backtitle "$__backtitle" --menu "Por favor elige el dispositivo Bluetooth que deseas eliminar." 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && return

        remove_bluetooth_device=$($(get_script_bluetooth bluez-test-device) remove $choice)
        if [[ -z "$remove_bluetooth_device" ]] ; then
            printMsgs "dialog" "Dispositivo eliminado"
        else
            printMsgs "dialog" "Se produjo un error al eliminar el dispositivo bluetooth. Por favor, asegúrate de haber escrito la dirección mac correctamente"
        fi
    fi
}

function register_bluetooth() {
    declare -A mac_addresses=()
    local mac_address
    local device_name
    local options=()

    while read mac_address; read device_name; do
        mac_addresses+=(["$mac_address"]="$device_name")
        options+=("$mac_address" "$device_name")
    done < <(list_available_bluetooth)

    if [[ ${#mac_addresses[@]} -eq 0 ]] ; then
        printMsgs "dialog" "No se encontraron dispositivos. Asegúrate de que el dispositivo esté encendido y vuelve a intentarlo"
        return
    fi

    local cmd=(dialog --backtitle "$__backtitle" --menu "Elige el dispositivo Bluetooth al que deseas conectarte." 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    mac_address="$choice"
    device_name="${mac_addresses[$choice]}"

    if [[ "$device_name" =~ "PLAYSTATION(R)3 Controller" ]]; then
        $(get_script_bluetooth bluez-test-device) disconnect "$mac_address" 2>&1
        $(get_script_bluetooth bluez-test-device) trusted "$mac_address" yes 2>&1
        local trusted=$($(get_script_bluetooth bluez-test-device) trusted "$mac_address" 2>&1)
        if [[ "$trusted" -eq 1 ]]; then
            printMsgs "dialog" "Autentificado correctamente $device_name ($mac_address).\n\nAhora puede quitar el cable USB."
        else
            printMsgs "dialog" "No se puede autentificar $device_name ($mac_address).\n\nIntenta volver a registrar el dispositivo, asegurándote de seguir exactamente los pasos en pantalla."
        fi
        return
    fi

    local cmd=(dialog --backtitle "$__backtitle" --menu "Elige el modo de seguridad: prueba el primero y luego el segundo si falla." 22 76 16)
    options=(
        1 "DisplayYesNo"
        2 "KeyboardDisplay"
        3 "NoInputNoOutput"
        4 "DisplayOnly"
        5 "KeyboardOnly"
    )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    local mode="${options[choice*2-1]}"

    # create a named pipe & fd for input for bluez-simple-agent
    local fifo="$(mktemp -u)"
    mkfifo "$fifo"
    exec 3<>"$fifo"
    local line
    local pin
    local error=""
    local skip_connect=0
    while read -r line; do
        case "$line" in
            "RequestPinCode"*)
                cmd=(dialog --nocancel --backtitle "$__backtitle" --menu "Por favor elige un pin" 22 76 16)
                options=(
                    1 "Pin 0000"
                    2 "Introduce tu propio Pin"
                )
                choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                pin="0000"
                if [[ "$choice" == "2" ]]; then
                    pin=$(dialog --backtitle "$__backtitle" --inputbox "Por favor introduce un pin" 10 60 2>&1 >/dev/tty)
                fi
                dialog --backtitle "$__backtitle" --infobox "Por favor introduce pin $pin en tu dispositivo bluetooth" 10 60
                echo "$pin" >&3
                # read "Enter PIN Code:"
                read -n 15 line
                ;;
            "RequestConfirmation"*)
                # read "Confirm passkey (yes/no): "
                echo "yes" >&3
                read -n 26 line
                skip_connect=1
                break
                ;;
            "DisplayPasskey"*|"DisplayPinCode"*)
                # extract key from end of line
                # DisplayPasskey (/org/bluez/1284/hci0/dev_01_02_03_04_05_06, 123456)
                [[ "$line" =~ ,\ (.+)\) ]] && pin=${BASH_REMATCH[1]}
                dialog --backtitle "$__backtitle" --infobox "Por favor introduce pin $pin en tu dispositivo bluetooth" 10 60
                ;;
            "Creating device failed"*)
                error="$line"
                ;;
        esac
    # read from bluez-simple-agent buffered line by line
    done < <(stdbuf -oL $(get_script_bluetooth bluez-simple-agent) -c "$mode" hci0 "$mac_address" <&3)
    exec 3>&-
    rm -f "$fifo"

    if [[ "$skip_connect" -eq 1 ]]; then
        if hcitool con | grep -q "$mac_address"; then
            printMsgs "dialog" "Registrado exitosamente y conectado a $mac_address"
            return 0
        else
            printMsgs "dialog" "No se puede conectar al dispositivo bluetooth. Por favor intenta emparejar con la herramienta de línea de comandos 'bluetoothctl'"
            return 1
        fi
    fi

    if [[ -z "$error" ]]; then
        error=$($(get_script_bluetooth bluez-test-device) trusted "$mac_address" yes 2>&1)
        if [[ -z "$error" ]] ; then
            error=$($(get_script_bluetooth bluez-test-input) connect "$mac_address" 2>&1)
            if [[ -z "$error" ]]; then
                printMsgs "dialog" "Registrado exitosamente y conectado a $mac_address"
                return 0
            fi
        fi
    fi

    printMsgs "dialog" "Se ha producido un error al conectar el dispositivo bluetooth. ($error)"
    return 1
}

function udev_bluetooth() {
    declare -A mac_addresses=()
    local mac_address
    local device_name
    local options=()
    while read mac_address; read device_name; do
        mac_addresses+=(["$mac_address"]="$device_name")
        options+=("$mac_address" "$device_name")
    done < <(list_registered_bluetooth)

    if [[ ${#mac_addresses[@]} -eq 0 ]] ; then
        printMsgs "dialog" "No hay dispositivos bluetooth registrados."
    else
        local cmd=(dialog --backtitle "$__backtitle" --menu "Elige el dispositivo Bluetooth para el que desea crear una regla de udev" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && return
        device_name="${mac_addresses[$choice]}"
        local config="/etc/udev/rules.d/99-bluetooth.rules"
        if ! grep -q "$device_name" "$config"; then
            local line="SUBSYSTEM==\"input\", ATTRS{name}==\"$device_name\", MODE=\"0666\", ENV{ID_INPUT_JOYSTICK}=\"1\""
            addLineToFile "$line" "$config"
            printMsgs "dialog" "Se agregó $line a $config \n\nPor favor reinicia para que la configuración surta efecto."
        else
            printMsgs "dialog" "Ya existe una entrada para $device_name en $config"
        fi
    fi
}

function connect_bluetooth() {
    local mac_address
    local device_name
    while read mac_address; read device_name; do
        $($(get_script_bluetooth bluez-test-input) connect "$mac_address" 2>/dev/null)
    done < <(list_registered_bluetooth)
}

function boot_bluetooth() {
    connect_mode="$(_get_connect_mode)"
    case "$connect_mode" in
        boot)
            connect_bluetooth
            ;;
        background)
            local script=""
            local macs=()
            local mac_address
            local device_name
            while read mac_address; read device_name; do
                macs+=($mac_address)
            done < <(list_registered_bluetooth)
            local script="while true; do for mac in ${macs[@]}; do hcitool con | grep -q \"\$mac\" || { echo \"connect \$mac\nquit\"; sleep 1; } | bluetoothctl >/dev/null 2>&1; sleep 10; done; done"
            nohup nice -n19 /bin/sh -c "$script" >/dev/null &
            ;;
    esac
}

function connect_mode_bluetooth() {
    local connect_mode="$(_get_connect_mode)"

    local cmd=(dialog --backtitle "$__backtitle" --default-item "$connect_mode" --menu "Choose a connect mode" 22 76 16)

    local options=(
        default "Comportamiento predeterminado de la pila Bluetooth (recomendado)"
        boot "Conectarse a dispositivos una vez en el arranque"
        background "Forzar la conexión a dispositivos en segundo plano"
    )

    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    local config="/etc/systemd/system/connect-bluetooth.service"
    case "$choice" in
        boot|background)
            local type="simple"
            [[ "$choice" == "background" ]] && type="forking"
            cat > "$config" << _EOF_
[Unit]
Description=Connect Bluetooth

[Service]
Type=$type
ExecStart=/bin/bash "$scriptdir/emulos_pkgs.sh" bluetooth boot

[Install]
WantedBy=multi-user.target
_EOF_
            systemctl enable "$config"
            ;;
        default)
            if systemctl is-enabled connect-bluetooth | grep -q "enabled"; then
               systemctl disable "$config"
            fi
            rm -f "$config"
            ;;
    esac
    iniConfig "=" '"' "$configdir/all/bluetooth.cfg"
    iniSet "connect_mode" "$choice"
    chown $user:$user "$configdir/all/bluetooth.cfg"
}

function gui_bluetooth() {
    addAutoConf "8bitdo_hack" 0

    while true; do
        local connect_mode="$(_get_connect_mode)"

        local cmd=(dialog --backtitle "$__backtitle" --menu "Configurar dispositivos Bluetooth" 22 76 16)
        local options=(
            R "Registrar y conectar al dispositivo Bluetooth"
            X "Eliminar dispositivo Device"
            D "Mostrar dispositivos Bluetooth registrados y conectados"
            U "Configurar la regla udev para Joypad (requerido para los joypads de 8Bitdo, etc.)"
            C "Conectar ahora a todos los dispositivos registrados."
            M "Configurar el modo de conexión de Bluetooth (actualmente: $connect_mode)"
        )

        local atebitdo
        if getAutoConf 8bitdo_hack; then
            atebitdo=1
            options+=(8 "8Bitdo mapeo hack (ON - firmware antiguo)")
        else
            atebitdo=0
            options+=(8 "8Bitdo mapeo hack (OFF - nuevo firmware)")
        fi

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            # temporarily restore Bluetooth stack (if needed)
            service sixad status &>/dev/null && sixad -r
            case "$choice" in
                R)
                    register_bluetooth
                    ;;
                X)
                    remove_device_bluetooth
                    ;;
                D)
                    display_active_and_registered_bluetooth
                    ;;
                U)
                    udev_bluetooth
                    ;;
                C)
                    connect_bluetooth
                    ;;
                M)
                    connect_mode_bluetooth
                    ;;
                8)
                    atebitdo="$((atebitdo ^ 1))"
                    setAutoConf "8bitdo_hack" "$atebitdo"
                    ;;
            esac
        else
            # restart sixad (if running)
            service sixad status &>/dev/null && service sixad restart && printMsgs "dialog" "AVISO: el controlador del mando ps3 se interrumpió temporalmente para permitir la compatibilidad con los periféricos Bluetooth estándar. Vuelva a emparejar su controlador Dual Shock para continuar (o ignore este mensaje si actualmente está usando otro controlador)."
            break
        fi
    done
}
