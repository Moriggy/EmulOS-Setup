#!/usr/bin/env bash

# This file is part of The MasOS Team Project
#
# The MasOS Team Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/Moriggy/EmulOS-Setup/master/LICENSE.md
#

rp_module_id="attractmode"
rp_module_desc="Instalación del frontend Attract Mode"
rp_module_licence="GPL3 https://raw.githubusercontent.com/mickelson/attract/master/License.txt"
rp_module_section="exp"
rp_module_flags="!mali !kms frontend"

function _get_configdir_attractmode() {
    echo "$configdir/all/attractmode"
}

function _add_system_attractmode() {
    local attract_dir="$(_get_configdir_attractmode)"
    [[ ! -d "$attract_dir" || ! -f /usr/bin/attract ]] && return 0

    local fullname="$1"
    local name="$2"
    local path="$3"
    local extensions="$4"
    local command="$5"
    local platform="$6"
    local theme="$7"

    # replace any / characters in fullname
    fullname="${fullname//\/ }"

    local config="$attract_dir/emulators/$fullname.cfg"
    iniConfig " " "" "$config"
    # replace %ROM% with "[romfilename]" and convert to array
    command=(${command//%ROM%/\"[romfilename]\"})
    iniSet "executable" "${command[0]}"
    iniSet "args" "${command[*]:1}"

    iniSet "rompath" "$path"
    iniSet "system" "$fullname"

    # extensions separated by semicolon
    extensions="${extensions// /;}"
    iniSet "romext" "$extensions"

    # snap path
    local snap="videos"
    if [[ "$name" == "emulos" ]]; then
      user="$(cat /etc/passwd | grep '1000' | cut -d: -f1)"
      mkdir /home/$user/EmulOS/roms/emulos
      cat > /home/$user/EmulOS/roms/emulos/EmulationStation.sh <<_EOF_
#!/usr/bin/env bash
echo ""
echo "Cambiando el arranque a EmulationStation y reiniciando..."
echo ""
sed -i 's/attract/emulationstation/g' /opt/emulos/configs/all/autostart.sh
sleep 2
sudo reboot
_EOF_
        cat > /home/$user/EmulOS/emulosmenu/Attract-Mode.sh <<_EOF_
#!/usr/bin/env bash
echo ""
echo "Cambiando el arranque a Attract-Mode y reiniciando..."
echo ""
sed -i 's/emulationstation/attract/g' /opt/emulos/configs/all/autostart.sh
sleep 2
sudo reboot
_EOF_

        chmod +x /home/$user/EmulOS/emulosmenu/Attract-Mode.sh
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/audiosettings.rp >> "/home/$user/EmulOS/roms/emulos/Audio.sh"
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/bluetooth.rp >> "/home/$user/EmulOS/roms/emulos/Bluetooth.sh"
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/configedit.rp >> "/home/$user/EmulOS/roms/emulos/Editor de Configuracion.sh"
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/emulosextrasall.rp >> "/home/$user/EmulOS/roms/emulos/EmulOS Herramientas y utils.sh"
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/personalizaremulos.rp >> "/home/$user/EmulOS/roms/emulos/Personalizar EmulOS.sh"
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/wifi.rp >> "/home/$user/EmulOS/roms/emulos/Configurar Wifi.sh"
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/filemanager.rp >> "/home/$user/EmulOS/roms/emulos/Administrador de Archivos.sh"
        if [[ -f "/home/pi/EmulOS/emulosmenu/raspiconfig.rp" ]]; then
          echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/raspiconfig.rp >> "/home/$user/EmulOS/roms/emulos/Raspi-config.sh"
        fi
        echo sudo reboot >> "/home/$user/EmulOS/roms/emulos/Reiniar.sh"
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/retroarch.rp >> "/home/$user/EmulOS/roms/emulos/Retroarch.sh"
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/retronetplay.rp >> "/home/$user/EmulOS/roms/emulos/Retroarch Netplay.sh"
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/rpsetup.rp >> "/home/$user/EmulOS/roms/emulos/EmulOS-Setup.sh"
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/runcommand.rp >> "/home/$user/EmulOS/roms/emulos/RunCommand Configuracion.sh"
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/systeminfo.rp >> "/home/$user/EmulOS/roms/emulos/Informacion del sistema.sh"
        echo sudo poweroff >> "/home/$user/EmulOS/roms/emulos/Apagar.sh"
        echo sudo /home/$user/EmulOS-Setup/emulos_pkgs.sh emulosmenu launch /home/$user/EmulOS/emulosmenu/splashscreen.rp >> "/home/$user/EmulOS/roms/emulos/Configurar Splash Screen.sh"
        mkdir /home/$user/EmulOS/roms/emulos/snap
        mkdir /home/$user/EmulOS/roms/emulos/videos
        cp /home/$user/EmulOS/emulosmenu/icons/audiosettings.png /home/$user/EmulOS/roms/emulos/snap/Audio.png
        cp /home/$user/EmulOS/emulosmenu/icons/bluetooth.png /home/$user/EmulOS/roms/emulos/snap/Bluetooth.png
        cp /home/$user/EmulOS/emulosmenu/icons/configedit.png "/home/$user/EmulOS/roms/emulos/snap/Editor de Configuracion.png"
        cp /home/$user/EmulOS/emulosmenu/icons/personalizaremulos.png "/home/$user/EmulOS/roms/emulos/snap/Personalizar EmulOS.png"
        cp /home/$user/EmulOS/emulosmenu/icons/emulosextrasall.png "/home/$user/EmulOS/roms/emulos/snap/EmulOS Herramientas y utils.png"
        cp /home/$user/EmulOS/emulosmenu/icons/wifi.png "/home/$user/EmulOS/roms/emulos/snap/Configurar Wifi.png"
        cp /home/$user/EmulOS/emulosmenu/icons/filemanager.png "/home/$user/EmulOS/roms/emulos/snap/Administrador de Archivos.png"
        cp /home/$user/EmulOS/emulosmenu/icons/raspiconfig.png /home/$user/EmulOS/roms/emulos/snap/Raspi-config.png
        cp /home/$user/EmulOS/emulosmenu/icons/retroarch.png /home/$user/EmulOS/roms/emulos/snap/Retroarch.png
        cp /home/$user/EmulOS/emulosmenu/icons/retronetplay.png "/home/$user/EmulOS/roms/emulos/snap/Retroarch Netplay.png"
        cp /home/$user/EmulOS/emulosmenu/icons/rpsetup.png /home/$user/EmulOS/roms/emulos/snap/EmulOS-Setup.png
        cp /home/$user/EmulOS/emulosmenu/icons/runcommand.png "/home/$user/EmulOS/roms/emulos/snap/RunCommand Configuracion.png"
        cp /home/$user/EmulOS/emulosmenu/icons/systeminfo.png "/home/$user/EmulOS/roms/emulos/snap/Informacion del sistema.png"
        cp /home/$user/EmulOS/emulosmenu/icons/splashscreen.png "/home/$user/EmulOS/roms/emulos/snap/Configurar Splash Screen.png"
        chmod +x /home/$user/EmulOS/roms/emulos/*.sh
        wget http://attractmode.org/images/logo.png
        mv logo.png /home/$user/EmulOS/emulosmenu/icons/Attract-Mode.png
        cat > /home/$user/.attract/emulators/EmulOS.cfg <<_EOF_
# Generated by Attract-Mode v2.5.1
#
executable           /bin/bash
args                 "[romfilename]"
rompath              /home/$user/EmulOS/roms/emulos
romext               .sh
system               EmulOS
artwork    box       /home/$user/EmulOS/roms/emulos/box
artwork    cart      /home/$user/EmulOS/roms/emulos/cart
artwork    flyer     /home/$user/EmulOS/roms/emulos/box
artwork    marquee   /home/$user/EmulOS/roms/emulos/marquee
artwork    snap      /home/$user/EmulOS/roms/emulos/video;/home/$user/EmulOS/roms/emulos/snap
artwork    wheel     /home/$user/EmulOS/roms/emulos/wheel
_EOF_

      sed -i '/\<sound\>/i \display EmulOS' /home/$user/.attract/attract.cfg
      sed -i '/\<sound\>/i \        layout               robo' /home/$user/.attract/attract.cfg
      sed -i '/\<sound\>/i \        romlist              EmulOS' /home/$user/.attract/attract.cfg
      sed -i '/\<sound\>/i \        in_cycle             yes' /home/$user/.attract/attract.cfg
      sed -i '/\<sound\>/i \        in_menu              yes' /home/$user/.attract/attract.cfg
      sed -i '/\<sound\>/i \        filter               all' /home/$user/.attract/attract.cfg
      sed -i '/\<sound\>/i \ ' /home/$user/.attract/attract.cfg
      sed -i 's/window_mode          default/window_mode          fullscreen/g' /home/$user/.attract/attract.cfg
      attract -b EmulOS
      sed -i '/<\<gameList\>>/a \        </game>' /opt/emulos/configs/all/emulationstation/gamelists/emulos/gamelist.xml
      sed -i '/<\<gameList\>>/a \                <image>./icons/Attract-Mode.png</image>' /opt/emulos/configs/all/emulationstation/gamelists/emulos/gamelist.xml
      sed -i '/<\<gameList\>>/a \                <desc>Cambiar el arranque a Attract-Mode y reinicia el sistema.</desc>' /opt/emulos/configs/all/emulationstation/gamelists/emulos/gamelist.xml
      sed -i '/<\<gameList\>>/a \                <name>Attract-Mode</name>' /opt/emulos/configs/all/emulationstation/gamelists/emulos/gamelist.xml
      sed -i '/<\<gameList\>>/a \                <path>./Attract-Mode.sh</path>' /opt/emulos/configs/all/emulationstation/gamelists/emulos/gamelist.xml
      sed -i '/<\<gameList\>>/a \        <game>' /opt/emulos/configs/all/emulationstation/gamelists/emulos/gamelist.xml

    else
      iniSet "artwork flyer" "$path/media/images"
      iniSet "artwork marquee" "$path/media/marquee"
      iniSet "artwork snap" "$path/media/$snap"
      iniSet "artwork wheel" "$path/media/wheel"
    fi
    chown $user:$user "$config"

    # if no gameslist, generate one
    if [[ ! -f "$attract_dir/romlists/$fullname.txt" ]]; then
        sudo -u $user attract --build-romlist "$fullname" -o "$fullname"
    fi

    local config="$attract_dir/attract.cfg"
    local tab=$'\t'
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
}

function _del_system_attractmode() {
    local attract_dir="$(_get_configdir_attractmode)"
    [[ ! -d "$attract_dir" ]] && return 0

    local fullname="$1"
    local name="$2"

    rm -rf "$attract_dir/romlists/$fullname.txt"

    local tab=$'\t'
    # eliminando el bloque de visualización de "^display $tab $fullname" al siguiente "^display" o línea vacía manteniendo la siguiente línea de visualización
    sed -i "/^display$tab$fullname/,/^display\|^$/{/^display$tab$fullname/d;/^display\$/!d}" "$attract_dir/attract.cfg"
}

function _add_rom_attractmode() {
    local attract_dir="$(_get_configdir_attractmode)"
    [[ ! -d "$attract_dir" ]] && return 0

    local system_name="$1"
    local system_fullname="$2"
    local path="$3"
    local name="$4"
    local desc="$5"
    local image="$6"

    local config="$attract_dir/romlists/$system_fullname.txt"

    # remove extension
    path="${path/%.*}"

    if [[ ! -f "$config" ]]; then
        echo "#Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons" >"$config"
    fi

    # if the entry already exists, remove it
    if grep -q "^$path;" "$config"; then
        sed -i "/^$path/d" "$config"
    fi

    echo "$path;$name;$system_fullname;;;;;;;;;;;;;;" >>"$config"
    chown $user:$user "$config"
}

function depends_attractmode() {
    local depends=(
        cmake libflac-dev libogg-dev libvorbis-dev libopenal-dev libfreetype6-dev
        libudev-dev libjpeg-dev libudev-dev libavutil-dev libavcodec-dev
        libavformat-dev libavfilter-dev libswscale-dev libavresample-dev
        libfontconfig1-dev
    )
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    isPlatform "x11" && depends+=(libsfml-dev)
    getDepends "${depends[@]}"
}

function sources_attractmode() {
    isPlatform "rpi" && gitPullOrClone "$md_build/sfml-pi" "https://github.com/mickelson/sfml-pi"
    gitPullOrClone "$md_build/attract" "https://github.com/mickelson/attract"
}

function build_attractmode() {
    if isPlatform "rpi"; then
        cd sfml-pi
        cmake . -DCMAKE_INSTALL_PREFIX="$md_inst/sfml" -DSFML_RPI=1 -DEGL_INCLUDE_DIR=/opt/vc/include -DEGL_LIBRARY=/opt/vc/lib/libbrcmEGL.so -DGLES_INCLUDE_DIR=/opt/vc/include -DGLES_LIBRARY=/opt/vc/lib/libbrcmGLESv2.so
        make clean
        make
        cd ..
    fi
    cd attract
    make clean
    local params=(prefix="$md_inst")
    isPlatform "rpi" && params+=(USE_GLES=1 EXTRA_CFLAGS="$CFLAGS -I$md_build/sfml-pi/include -L$md_build/sfml-pi/lib")
    make "${params[@]}"

    # remove example configs
    rm -rf "$md_build/attract/config/emulators/"*

    md_ret_require="$md_build/attract/attract"
}

function install_attractmode() {
    make -C sfml-pi install
    mkdir -p "$md_inst"/{bin,share,share/attract}
    cp -v attract/attract "$md_inst/bin/"
    cp -Rv attract/config/* "$md_inst/share/attract"
}

function remove_attractmode() {
    user="$(cat /etc/passwd | grep '1000' | cut -d: -f1)"
    rm -f /usr/bin/attract
    rm -R /home/$user/EmulOS/roms/emulos
    rm -R /opt/emulos/configs/all/attractmode
}

function configure_attractmode() {
    moveConfigDir "$home/.attract" "$md_conf_root/all/attractmode"
    user="$(cat /etc/passwd | grep '1000' | cut -d: -f1)"

    [[ "$md_mode" == "remove" ]] && return

    local config="$md_conf_root/all/attractmode/attract.cfg"
    if [[ ! -f "$config" ]]; then
        echo "general" >"$config"
        echo -e "\tlanguage          es" >>"$config"
        echo -e "\tstartup_mode          displays_menu" >>"$config"
        echo -e "\twindow_mode          fullscreen" >>"$config"
        echo -e "\tvideo_decoder          mmal" >>"$config"
        echo -e "\tmenu_prompt          Displays Menu" >>"$config"
        echo -e "\tmenu_layout          robospin_v4" >>"$config"

        echo "layout_config	robospin_v4" >>"$config"
        echo -e "\tparam                enable_Lmarquee No" >>"$config"
        echo -e "\tparam                enable_bg blue" >>"$config"
        echo -e "\tparam                enable_bloom No" >>"$config"
        echo -e "\tparam                enable_cab moon" >>"$config"
        echo -e "\tparam                enable_colors yes" >>"$config"
        echo -e "\tparam                enable_crt No" >>"$config"
        echo -e "\tparam                enable_frame yes" >>"$config"
        echo -e "\tparam                enable_list_type wheel" >>"$config"
        echo -e "\tparam                enable_marquee Yes" >>"$config"
        echo -e "\tparam                enable_mlogos Yes" >>"$config"
        echo -e "\tparam                enable_overlay mask" >>"$config"
        echo -e "\tparam                enable_pointer rocket" >>"$config"
        echo -e "\tparam                enable_slogos Yes" >>"$config"
        echo -e "\tparam                enable_static yes" >>"$config"
        echo -e "\tparam                orbit_art wheel" >>"$config"
        echo -e "\tparam                transition_ms 35" >>"$config"
    fi

    mkUserDir "$md_conf_root/all/attractmode/emulators"
    cat >/usr/bin/attract <<_EOF_
#!/bin/bash
LD_LIBRARY_PATH="$md_inst/sfml/lib" "$md_inst/bin/attract" "\$@"
_EOF_
    chmod +x "/usr/bin/attract"
    wget https://github.com/DOCK-PI3/attract-config-rpi/archive/master.zip && unzip master.zip
    rm master.zip
    cd attract-config-rpi-master/attract/
    mv layouts/ /opt/emulos/configs/all/attractmode
    mv menu-art/ /opt/emulos/configs/all/attractmode
    cd
    rm -R /home/$user/attract-config-rpi-master/
    #mkdir /opt/emulos/configs/all/attractmode/amboot
    #cp $scriptdir/scriptmodules/extras/scripts/amromlist.sh /opt/emulos/configs/all/attractmode/amboot
    #chmod +x /opt/emulos/configs/all/attractmode/amboot/amromlist.sh
    chown -R $user:$user /opt/emulos/configs/all/attractmode

    local idx
    for idx in "${__mod_idx[@]}"; do
        if rp_isInstalled "$idx" && [[ -n "${__mod_section[$idx]}" ]] && ! hasFlag "${__mod_flags[$idx]}" "frontend"; then
            rp_callModule "$idx" configure
        fi
    done
}
