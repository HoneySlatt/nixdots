{ pkgs, ... }:

{
  home.packages = [

    # Toggle HDR on monitor DP-2
    # Keybind: SUPER + CTRL + H
    (pkgs.writeShellApplication {
      name = "toggle-hdr";
      runtimeInputs = [ pkgs.hyprland pkgs.libnotify pkgs.jq ];
      text = ''
        BASE_CONFIG="DP-2, 3840x2160@240, 0x0, 1.5, bitdepth, 10"

        current=$(hyprctl monitors -j | jq -r '.[] | select(.name == "DP-2") | .colorManagementPreset')

        if [ "$current" = "hdr" ]; then
          hyprctl keyword monitor "$BASE_CONFIG"
          notify-send "HDR" "Disabled"
        else
          hyprctl keyword monitor "$BASE_CONFIG, cm, hdr,"
          notify-send "HDR" "Enabled"
        fi
      '';
    })

    # Toggle ProtonVPN connection (fastest server)
    # Keybind: SUPER + SHIFT + V
    (pkgs.writeShellApplication {
      name = "toggle-protonvpn";
      runtimeInputs = [ pkgs.proton-vpn-cli pkgs.iproute2 pkgs.libnotify ];
      text = ''
        if ip link show proton0 &>/dev/null; then
          protonvpn disconnect
          notify-send "ProtonVPN" "Disconnected"
        else
          protonvpn connect
          notify-send "ProtonVPN" "Connecting..."
        fi
      '';
    })

    # Random wallpaper rotation using awww
    # Called at autostart
    (pkgs.writeShellApplication {
      name = "wallpaper-rotation";
      runtimeInputs = [ pkgs.awww pkgs.findutils pkgs.coreutils ];
      text = ''
        THEME_FILE="$HOME/.config/quickshell/.current-theme"
        BASE_DIR="$HOME/Pictures/Wallpapers"

        declare -A THEME_DIRS
        THEME_DIRS[catppuccin]="CatppuccinMocha"
        THEME_DIRS[rosepine]="RosePine"
        THEME_DIRS[everforest]="Everforest"
        THEME_DIRS[carbonfox]="Carbonfox"
        THEME_DIRS[gruvbox]="GruvboxDark"
        THEME_DIRS[gruvbox-light]="GruvboxLight"

        while true; do
          theme=$(cat "$THEME_FILE" 2>/dev/null | tr -d '[:space:]')
          subdir="''${THEME_DIRS[$theme]:-CatppuccinMocha}"
          WALLPAPER_DIR="$BASE_DIR/$subdir"

          wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
          if [ -n "$wallpaper" ]; then
            awww img "$wallpaper" --transition-type wave --transition-duration 2
          fi
          sleep 300
        done
      '';
    })

    # Toggle hyprquickshot / stop screen recording
    # Keybind: SUPER + S
    (pkgs.writeShellApplication {
      name = "hyprquickshot-toggle";
      runtimeInputs = [ pkgs.quickshell pkgs.procps ];
      text = ''
        if pgrep -x wf-recorder > /dev/null; then
          pkill --signal SIGINT wf-recorder
        else
          quickshell -c hyprquickshot -n
        fi
      '';
    })

  ];
}
