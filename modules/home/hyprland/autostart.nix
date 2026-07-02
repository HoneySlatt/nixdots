{ lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  wayland.windowManager.hyprland.settings = {
    on = {
      _args = [
        "hyprland.start"
        (mkLuaInline ''
          function()
            hl.exec_cmd("systemctl --user start hyprpolkitagent")
            hl.exec_cmd("swaync")
            hl.exec_cmd("start-quickshell")
            hl.exec_cmd("awww-daemon")
            hl.exec_cmd("wallpaper-rotation")
            hl.exec_cmd("steam -silent")
            hl.exec_cmd("sleep 15 && jellyfin-mpv-shim")
          end
        '')
      ];
    };
  };
}
