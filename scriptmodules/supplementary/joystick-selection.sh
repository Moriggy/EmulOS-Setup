#!/usr/bin/env bash

rp_module_id="joystick-selection"
rp_module_desc="Configure los mandos para 1-4 jugadores en RetroArch (global o especifico del sistema)."
rp_module_help="Siga las instrucciones en los cuadros de dialogo para configurar que joystick usar para los jugadores RetroArch 1-4 (global o especifico del sistema)."
rp_module_section="exp"

function depends_joystick-selection() {
    getDepends "libsdl2-dev"
}

function sources_joystick-selection() {
    gitPullOrClone "$md_build" "https://github.com/meleu/RetroPie-joystick-selection.git"
}

function build_joystick-selection() {
    gcc "$md_build/jslist.c" -o "$md_build/jslist" $(sdl2-config --cflags --libs)
}

function install_joystick-selection() {
    local gamelistxml="$datadir/retropiemenu/gamelist.xml"
    local rpmenu_js_sh="$datadir/retropiemenu/joystick_selection.sh"

    ln -sfv "$md_inst/joystick_selection.sh" "$rpmenu_js_sh"
    # maybe the user is using a partition that doesn't support symbolic links...
    [[ -L "$rpmenu_js_sh" ]] || cp -v "$md_inst/joystick_selection.sh" "$rpmenu_js_sh"

    cp -v "$md_build/icon.png" "$datadir/retropiemenu/icons/joystick_selection.png"

    cp -nv "$configdir/all/emulationstation/gamelists/retropie/gamelist.xml" "$gamelistxml"
    if grep -vq "<path>./joystick_selection.sh</path>" "$gamelistxml"; then
        xmlstarlet ed -L -P -s "/gameList" -t elem -n "gameTMP" \
            -s "//gameTMP" -t elem -n path -v "./joystick_selection.sh" \
            -s "//gameTMP" -t elem -n name -v "Joystick Selection" \
            -s "//gameTMP" -t elem -n desc -v "Seleccione que joystick usar para los jugadores RetroArch 1-4 (global o especifico del sistema)." \
            -s "//gameTMP" -t elem -n image -v "./icons/joystick_selection.png" \
            -r "//gameTMP" -v "game" \
            "$gamelistxml"

        # XXX: I don't know why the -P (preserve original formatting) isn't working,
        #      The new xml element for joystick_selection tool are all in only one line.
        #      Then let's format gamelist.xml.
        local tmpxml=$(mktemp)
        xmlstarlet fo -t "$gamelistxml" > "$tmpxml"
        cat "$tmpxml" > "$gamelistxml"
        rm -f "$tmpxml"
    fi

    # needed for proper permissions for gamelist.xml and icons/joystick_selection.png
    chown -R $user:$user "$datadir/retropiemenu"

    md_ret_files=(
        'jslist'
        'jsfuncs.sh'
        'joystick_selection.sh'
    )
}

function remove_joystick-selection() {
    rm -rfv "$configdir"/*/joystick-selection.cfg "$datadir/retropiemenu/icons/joystick_selection.png" "$datadir/retropiemenu/joystick_selection.sh"
    xmlstarlet ed -P -L -d "/gameList/game[contains(path,'joystick_selection.sh')]" "$datadir/retropiemenu/gamelist.xml"
}

function gui_joystick-selection() {
    bash "$md_inst/joystick_selection.sh"
}
