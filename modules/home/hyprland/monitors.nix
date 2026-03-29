{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Monitors
    monitor = [
      "DP-2, 3840x2160@240, 0x0, 1.5, bitdepth, 10"
      "DP-3, 1920x1080@180, 2560x0, 1"
    ];

    # Workspace-to-monitor assignments (odd on DP-2, even on DP-3)
    workspace = [
      "1,monitor:DP-2"
      "2,monitor:DP-3"
      "3,monitor:DP-2"
      "4,monitor:DP-3"
      "5,monitor:DP-2"
      "6,monitor:DP-3"
      "7,monitor:DP-2"
      "8,monitor:DP-3"
      "9,monitor:DP-2"
      "10,monitor:DP-3"
    ];
  };
}
