#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="retroarch"
rp_module_desc="RetroArch - frontend to the libretro emulator cores - required by all lr-* emulators"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/RetroArch/master/COPYING"
rp_module_section="core"

function depends_retroarch() {
    local depends=(build-essential libasound2-dev libudev-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    isPlatform "gles" && depends+=(libgles2-mesa-dev)
    isPlatform "mesa" && depends+=(libx11-xcb-dev)
    isPlatform "mali" && depends+=(mali-fbdev)
    isPlatform "x11" && depends+=(libx11-xcb-dev libpulse-dev libvulkan-dev)
    isPlatform "vero4k" && depends+=(vero3-userland-dev-osmc zlib1g-dev libfreetype6-dev)
    isPlatform "kms" && depends+=(libgbm-dev)

    if compareVersions "$__os_debian_ver" ge 9; then
        depends+=(libavcodec-dev libavformat-dev libavdevice-dev)
    fi

    # only install nvidia-cg-toolkit if it is available (as the non-free repo may not be enabled)
    if isPlatform "x86"; then
        if [[ -n "$(apt-cache search --names-only nvidia-cg-toolkit)" ]]; then
            depends+=(nvidia-cg-toolkit)
        fi
    fi

    getDepends "${depends[@]}"
}

function sources_retroarch() {
    gitPullOrClone "$md_build" https://github.com/libretro/RetroArch.git v1.8.0
    applyPatch "$md_data/01_hotkey_hack.diff"
    applyPatch "$md_data/02_disable_search.diff"
}

function build_retroarch() {
    CFLAGS='-mfpu=neon' ./configure --enable-alsa --enable-udev --enable-neon --disable-videocore --enable-opengles --enable-opengles3 --disable-opengl1 --enable-x11
    make clean
    make -j4
    md_ret_require="$md_build/retroarch"
}

function install_retroarch() {
    sudo make install
    md_ret_files=(
        'retroarch.cfg'
    )
}

function update_shaders_retroarch() {
    local dir="$configdir/all/retroarch/shaders"
    local branch=""
    isPlatform "rpi" && branch="rpi"
    # remove if not git repository for fresh checkout
    [[ ! -d "$dir/.git" ]] && rm -rf "$dir"
    gitPullOrClone "$dir" https://github.com/RetroPie/common-shaders.git "$branch"
    chown -R $user:$user "$dir"
}

function update_overlays_retroarch() {
    local dir="$configdir/all/retroarch/overlay"
    # remove if not a git repository for fresh checkout
    [[ ! -d "$dir/.git" ]] && rm -rf "$dir"
    gitPullOrClone "$configdir/all/retroarch/overlay" https://github.com/libretro/common-overlays.git
    chown -R $user:$user "$dir"
}

function update_assets_retroarch() {
    local dir="$configdir/all/retroarch/assets"
    # remove if not a git repository for fresh checkout
    [[ ! -d "$dir/.git" ]] && rm -rf "$dir"
    gitPullOrClone "$dir" https://github.com/libretro/retroarch-assets.git
    chown -R $user:$user "$dir"
}

function install_xmb_monochrome_assets_retroarch() {
    local dir="$configdir/all/retroarch/assets"
    [[ -d "$dir/.git" ]] && return
    [[ ! -d "$dir" ]] && mkUserDir "$dir"
    downloadAndExtract "$__archive_url/retroarch-xmb-monochrome.tar.gz" "$dir"
    chown -R $user:$user "$dir"
}

function _package_xmb_monochrome_assets_retroarch() {
    gitPullOrClone "$md_build/assets" https://github.com/libretro/retroarch-assets.git
    mkdir -p "$__tmpdir/archives"
    local archive="$__tmpdir/archives/retroarch-xmb-monochrome.tar.gz"
    rm -f "$archive"
    tar cvzf "$archive" -C "$md_build/assets" xmb/monochrome
}

function configure_retroarch() {
    [[ "$md_mode" == "remove" ]] && return

    addUdevInputRules

    # move / symlink the retroarch configuration
    moveConfigDir "$home/.config/retroarch" "$configdir/all/retroarch"

    # move / symlink our old retroarch-joypads folder
    moveConfigDir "$configdir/all/retroarch-joypads" "$configdir/all/retroarch/autoconfig"

    # move / symlink old assets / overlays and shader folder
    moveConfigDir "$md_inst/assets" "$configdir/all/retroarch/assets"
    moveConfigDir "$md_inst/overlays" "$configdir/all/retroarch/overlay"
    moveConfigDir "$md_inst/shader" "$configdir/all/retroarch/shaders"

    # install assets, cheats and shaders by default
    update_shaders_retroarch

	# install minimal assets
    install_xmb_monochrome_assets_retroarch

    local config="$(mktemp)"

    cp "$md_inst/retroarch.cfg" "$config"

    # query ES A/B key swap configuration
    local es_swap="false"
    getAutoConf "es_swap_a_b" && es_swap="true"

    # configure default options
    iniConfig " = " '"' "$config"
    iniSet "cache_directory" "/tmp/retroarch"
    iniSet "system_directory" "$biosdir"
    iniSet "config_save_on_exit" "false"
    iniSet "video_scale" "1.0"
    iniSet "video_threaded" "true"
    iniSet "video_smooth" "false"
    iniSet "video_aspect_ratio_auto" "true"
    iniSet "video_smooth" "false"
    iniSet "video_shader_enable" "true"
    iniSet "auto_shaders_enable" "false"
    iniSet "rgui_show_start_screen" "false"
    iniSet "rgui_browser_directory" "$romdir"
    iniSet "audio_out_rate" "44100"

    if ! isPlatform "x86"; then
        iniSet "video_threaded" "true"
    fi

    iniSet "core_options_path" "$configdir/all/retroarch-core-options.cfg"
    isPlatform "x11" && iniSet "video_fullscreen" "true"
    isPlatform "mesa" && iniSet "video_fullscreen" "true"

	# set default render resolution to 640x480 for rpi1
    if isPlatform "rpi1"; then
        iniSet "video_fullscreen_x" "640"
        iniSet "video_fullscreen_y" "480"
    fi

    # enable hotkey ("select" button)
    iniSet "input_enable_hotkey" "nul"
    iniSet "input_exit_emulator" "escape"

    # enable and configure rewind feature
    iniSet "rewind_enable" "false"
    iniSet "rewind_buffer_size" "10"
    iniSet "rewind_granularity" "2"
    iniSet "input_rewind" "r"

    # enable gpu screenshots
    iniSet "video_gpu_screenshot" "true"

    # enable and configure shaders
    iniSet "input_shader_next" "m"
    iniSet "input_shader_prev" "n"

    # configure keyboard mappings
    iniSet "input_player1_a" "x"
    iniSet "input_player1_b" "z"
    iniSet "input_player1_y" "a"
    iniSet "input_player1_x" "s"
    iniSet "input_player1_start" "enter"
    iniSet "input_player1_select" "rshift"
    iniSet "input_player1_l" "q"
    iniSet "input_player1_r" "w"
    iniSet "input_player1_left" "left"
    iniSet "input_player1_right" "right"
    iniSet "input_player1_up" "up"
    iniSet "input_player1_down" "down"

    # input settings
    iniSet "input_joypad_driver" "udev"
    iniSet "input_autodetect_enable" "true"
    iniSet "auto_remaps_enable" "true"
    iniSet "all_users_control_menu" "true"

    # rgui by default
    iniSet "menu_driver" "rgui"

    # hide online updater menu options and the restart option
    iniSet "menu_show_core_updater" "false"
    iniSet "menu_show_online_updater" "false"
    iniSet "menu_show_restart_retroarch" "false"

    # disable unnecessary xmb menu tabs
    iniSet "xmb_show_add" "false"
    iniSet "xmb_show_history" "false"
    iniSet "xmb_show_images" "false"
    iniSet "xmb_show_music" "false"

	# disable xmb menu driver icon shadows
    iniSet "xmb_shadows_enable" "false"

    # swap A/B buttons based on ES configuration
    iniSet "menu_swap_ok_cancel_buttons" "$es_swap"

    # disable 'press twice to quit'
    iniSet "quit_press_twice" "false"

    #aumento de letra de texto
    iniSet "video_font_size" "26.000000"

	# visual settings
    iniSet "content_show_add" "false"
    iniSet "content_show_favorites" "false"
    iniSet "content_show_history" "false"
    iniSet "content_show_images" "false"
    iniSet "content_show_music" "false"
    iniSet "content_show_netplay" "false"
    iniSet "content_show_playlists" "false"
    iniSet "content_show_settings" "true"
    iniSet "content_show_settings_password" ""
    iniSet "content_show_video" "false"
    iniSet "kiosk_mode_enable" "false"
    iniSet "kiosk_mode_password" ""
    iniSet "menu_battery_level_enable" "false"
    iniSet "menu_core_enable" "true"
    iniSet "menu_dynamic_wallpaper_enable" "false"
    iniSet "menu_enable_widgets" "false"
    iniSet "menu_entry_hover_color" "ff64ff64"
    iniSet "menu_entry_normal_color" "ffffffff"
    iniSet "menu_font_color_blue" "255"
    iniSet "menu_font_color_green" "255"
    iniSet "menu_font_color_red" "255"
    iniSet "menu_footer_opacity" "1.000000"
    iniSet "menu_framebuffer_opacity" "0.500000"
    iniSet "menu_header_opacity" "1.000000"
    iniSet "menu_horizontal_animation" "true"
    iniSet "menu_left_thumbnails" "0"
    iniSet "menu_linear_filter" "true"
    iniSet "menu_mouse_enable" "true"
    iniSet "menu_navigation_browser_filter_supported_extensions_enable" "true"
    iniSet "menu_navigation_wraparound_enable" "true"
    iniSet "menu_pause_libretro" "true"
    iniSet "menu_pointer_enable" "false"
    iniSet "menu_shader_pipeline" "0"
    iniSet "menu_show_advanced_settings" "true"
    iniSet "menu_show_configurations" "true"
    iniSet "menu_show_core_updater" "false"
    iniSet "menu_show_help" "false"
    iniSet "menu_show_information" "false"
    iniSet "menu_show_latency" "false"
    iniSet "menu_show_legacy_thumbnail_updater" "false"
    iniSet "menu_show_load_content" "false"
    iniSet "menu_show_load_core" "false"
    iniSet "menu_show_online_updater" "false"
    iniSet "menu_show_overlays" "true"
    iniSet "menu_show_quit_retroarch" "true"
    iniSet "menu_show_reboot" "false"
    iniSet "menu_show_restart_retroarch" "true"
    iniSet "menu_show_rewind" "false"
    iniSet "menu_show_shutdown" "true"
    iniSet "menu_show_sublabels" "true"
    iniSet "menu_swap_ok_cancel_buttons" "$es_swap"
    iniSet "menu_throttle_framerate" "true"
    iniSet "menu_thumbnails" "3"
    iniSet "menu_timedate_enable" "true"
    iniSet "menu_timedate_style" "1"
    iniSet "menu_title_color" "ff64ff64"
    iniSet "menu_unified_controls" "true"
    iniSet "menu_use_preferred_system_color_theme" "false"
    iniSet "menu_wallpaper" ""
    iniSet "menu_wallpaper_opacity" "0.500000"
    iniSet "ozone_menu_color_theme" "1"
    iniSet "quick_menu_show_add_to_favorites" "false"
    iniSet "quick_menu_show_cheats" "true"
    iniSet "quick_menu_show_close_content" "true"
    iniSet "quick_menu_show_controls" "true"
    iniSet "quick_menu_show_download_thumbnails" "false"
    iniSet "quick_menu_show_information" "false"
    iniSet "quick_menu_show_options" "true"
    iniSet "quick_menu_show_recording" "false"
    iniSet "quick_menu_show_reset_core_association" "false"
    iniSet "quick_menu_show_restart_content" "true"
    iniSet "quick_menu_show_resume_content" "true"
    iniSet "quick_menu_show_save_content_dir_overrides" "true"
    iniSet "quick_menu_show_save_core_overrides" "true"
    iniSet "quick_menu_show_save_game_overrides" "true"
    iniSet "quick_menu_show_save_load_state" "true"
    iniSet "quick_menu_show_set_core_association" "false"
    iniSet "quick_menu_show_shaders" "true"
    iniSet "quick_menu_show_start_recording" "false"
    iniSet "quick_menu_show_start_streaming" "false"
    iniSet "quick_menu_show_streaming" "false"
    iniSet "quick_menu_show_take_screenshot" "false"
    iniSet "quick_menu_show_undo_save_load_state" "false"
    iniSet "quit_press_twice" "false"
    iniSet "rgui_aspect_ratio" "0"
    iniSet "rgui_aspect_ratio_lock" "1"
    iniSet "rgui_background_filler_thickness_enable" "true"
    iniSet "rgui_border_filler_enable" "true"
    iniSet "rgui_border_filler_thickness_enable" "true"
    iniSet "rgui_browser_directory" "$romdir"
    iniSet "rgui_config_directory" "~/.config/retroarch/config"
    iniSet "rgui_extended_ascii" "false"
    iniSet "rgui_inline_thumbnails" "false"
    iniSet "rgui_internal_upscale_level" "0"
    iniSet "rgui_menu_color_theme" "4"
    iniSet "rgui_menu_theme_preset" ""
    iniSet "rgui_particle_effect" "0"
    iniSet "rgui_show_start_screen" "false"
    iniSet "rgui_swap_thumbnails" "false"
    iniSet "rgui_thumbnail_delay" "0"
    iniSet "rgui_thumbnail_downscaler" "0"
    iniSet "settings_show_achievements" "true"
    iniSet "settings_show_ai_service" "true"
    iniSet "settings_show_audio" "true"
    iniSet "settings_show_configuration" "true"
    iniSet "settings_show_core" "true"
    iniSet "settings_show_directory" "true"
    iniSet "settings_show_drivers" "true"
    iniSet "settings_show_frame_throttle" "true"
    iniSet "settings_show_input" "true"
    iniSet "settings_show_latency" "true"
    iniSet "settings_show_logging" "true"
    iniSet "settings_show_network" "true"
    iniSet "settings_show_onscreen_display" "true"
    iniSet "settings_show_playlists" "false"
    iniSet "settings_show_power_management" "false"
    iniSet "settings_show_recording" "true"
    iniSet "settings_show_saving" "true"
    iniSet "settings_show_user" "true"
    iniSet "settings_show_user_interface" "true"
    iniSet "settings_show_video" "true"
    iniSet "video_font_enable" "true"
    iniSet "video_font_path" ""
    iniSet "video_message_color" "33ff00"
    iniSet "video_message_pos_x" "0.050000"
    iniSet "video_message_pos_y" "0.050000"
    iniSet "video_msg_bgcolor_blue" "0"
    iniSet "video_msg_bgcolor_enable" "false"
    iniSet "video_msg_bgcolor_green" "0"
    iniSet "video_msg_bgcolor_opacity" "1.000000"
    iniSet "video_msg_bgcolor_red" "0"
    iniSet "user_language" "0"

	rm "$configdir/all/retroarch.cfg"
    copyDefaultConfig "$config" "$configdir/all/retroarch.cfg"
    rm "$config"

    # force settings on existing configs
    _set_config_option_retroarch "menu_driver" "rgui"
    _set_config_option_retroarch "menu_unified_controls" "true"
    _set_config_option_retroarch "quit_press_twice" "false"
    _set_config_option_retroarch "video_shader_enable" "true"

    # remapping hack for old 8bitdo firmware
    addAutoConf "8bitdo_hack" 0
}

function keyboard_retroarch() {
    if [[ ! -f "$configdir/all/retroarch.cfg" ]]; then
        printMsgs "dialog" "No se encontró el archivo de configuración de RetroArch en $configdir/all/retroarch.cfg"
        return
    fi
    local input
    local options
    local i=1
    local key=()
    while read input; do
        local parts=($input)
        key+=("${parts[0]}")
        options+=("${parts[0]}" $i 2 "${parts[*]:2}" $i 26 16 0)
        ((i++))
    done < <(grep "^[[:space:]]*input_player[0-9]_[a-z]*" "$configdir/all/retroarch.cfg")
    local cmd=(dialog --backtitle "$__backtitle" --form "Configuración de teclado en RetroArch" 22 48 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        local value
        local values
        readarray -t values <<<"$choice"
        iniConfig " = " "" "$configdir/all/retroarch.cfg"
        i=0
        for value in "${values[@]}"; do
            iniSet "${key[$i]}" "$value" >/dev/null
            ((i++))
        done
    fi
}

function hotkey_retroarch() {
    iniConfig " = " '"' "$configdir/all/retroarch.cfg"
    local cmd=(dialog --backtitle "$__backtitle" --menu "Elige el comportamiento deseado de las teclas de acceso rápido." 22 76 16)
    local options=(1 "Hotkeys activado. (por defecto)"
             2 "Pulsar ALT para activar hotkeys."
             3 "Hotkeys desactivado. Pulsa ESCAPE para abrir la RGUI.")
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
                iniSet "input_enable_hotkey" "nul"
                iniSet "input_exit_emulator" "escape"
                iniSet "input_menu_toggle" "F1"
                ;;
            2)
                iniSet "input_enable_hotkey" "alt"
                iniSet "input_exit_emulator" "escape"
                iniSet "input_menu_toggle" "F1"
                ;;
            3)
                iniSet "input_enable_hotkey" "escape"
                iniSet "input_exit_emulator" "nul"
                iniSet "input_menu_toggle" "escape"
                ;;
        esac
    fi
}

function gui_retroarch() {
    while true; do
        local names=(assets cheats overlays shaders)
        local dirs=(assets cheats overlays shaders)
        local options=()
        local name
        local dir
        local i=1
        for name in "${names[@]}"; do
            if [[ -d "$configdir/all/retroarch/${dirs[i-1]}/.git" ]]; then
                options+=("$i" "Gestionar $name (instalado)")
            else
                options+=("$i" "Gestionar $name (no instalado)")
            fi
            ((i++))
        done
        options+=(
            5 "Configurar teclado para usar con RetroArch"
            6 "Configurar el comportamiento de las teclas de acceso rápido del teclado para RetroArch"
            7 "Restablecer las configuraciones retroarch y retroarch-core-option"
        )
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        case "$choice" in
            1|2|3|4)
                name="${names[choice-1]}"
                dir="${dirs[choice-1]}"
                options=(1 "Instalar/Actualizar $name" 2 "Desinstalar $name" )
                cmd=(dialog --backtitle "$__backtitle" --menu "Elige una opción para $dir" 12 40 06)
                choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

                case "$choice" in
                    1)
                        "update_${name}_retroarch"
                        ;;
                    2)
                        rm -rf "$configdir/all/retroarch/$dir"
                        ;;
                    *)
                        continue
                        ;;

                esac
                ;;
            5)
                keyboard_retroarch
                ;;
            6)
                hotkey_retroarch
                ;;
            7)
                config_retroarch
                printMsgs "dialog" "Completado el restablecimiento de las configuraciones retroarch y retroarch-core-options."
                ;;
            *)
                break
                ;;
        esac

    done
}

function _set_config_option_retroarch() {
    local option="$1"
    local value="$2"
    iniConfig " = " "\"" "$configdir/all/retroarch.cfg"
    iniGet "$option"
    if [[ -z "$ini_value" ]]; then
        iniSet "$option" "$value"
    fi
}
