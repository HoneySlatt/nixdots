{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "systemctl --user start hyprpolkitagent"
      "hyprlock"
      "qs -c bar"
      "awww-daemon"
      "sleep 1 && wallpaper-rotation"
      "sleep 2 && /home/honey/.config/quickshell/scripts/switch-theme.sh $(cat /home/honey/.config/quickshell/.current-theme)"
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"
      "swayosd-server"
      "steam -silent"
      "sleep 15 && jellyfin-mpv-shim"
    ];
  };
}
