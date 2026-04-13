{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";

    bind = [
      # App launchers
      "CONTROLSHIFT, T, exec, $terminal"
      "$mainMod, Q, killactive,"
      "$mainMod, e, exec, $terminal -e yazi"
      "$mainMod SHIFT, e, exec, [float; size 1350 750] $terminal -e yazi"
      "$mainMod, V, togglefloating,"
      "$mainMod, space, exec, $menu"
      "$mainMod SHIFT, P, exec, hyprpicker"
      "$mainMod, S, exec, hyprquickshot-toggle"
      "$mainMod SHIFT, S, exec, if hyprctl getoption general:layout | grep -q dwindle; then hyprctl keyword general:layout scrolling; else hyprctl keyword general:layout dwindle; fi"
      "$mainMod SHIFT, W, exec, quickshell ipc -p ~/.config/quickshell/bar -n call togglePosition call"
      "$mainMod CTRL, W, exec, quickshell ipc -p ~/.config/quickshell/bar -n call toggleVisibility call"
      "$mainMod, G, exec, qs msg -c bar toggleSteamLauncher call"
      "$mainMod, T, exec, qs msg -c bar toggleThemeLauncher call"
      "$mainMod, W, exec, qs msg -c bar toggleWallpaperLauncher call"
      "$mainMod, B, exec, helium"
      "$mainMod, M, exec, cider-2"
      "$mainMod CTRL, M, exec, qs msg -c bar toggleCiderLauncher call"
      "$mainMod, D, exec, vesktop"
      "$mainMod, O, exec, obsidian"
      "$mainMod SHIFT, M, exec, tutanota-desktop --no-sandbox %U"
      ''$mainMod SHIFT, O, exec, $terminal zsh -c "yazi ~/Obsidian\ Vault/"''
      "$mainMod SHIFT, N, exec, jellyfin-desktop"
      "$mainMod SHIFT, V, exec, toggle-protonvpn"
      "$mainMod CTRL, H, exec, toggle-hdr"
      "$mainMod, F, fullscreen, 1"
      "$mainMod, R, exec, qs ipc -c bar call togglePowerMenu call"
      "$mainMod, C, exec, kitty -e claude"
      "$mainMod, N, exec, kitty -e nvim"
      "$mainMod, TAB, exec, qs ipc -c bar call overview toggle"
      "ctrl alt, delete, exec, kitty -e btop"

      # Move focus with HJKL
      "$mainMod, H, movefocus, l"
      "$mainMod, L, movefocus, r"
      "$mainMod, K, movefocus, u"
      "$mainMod, J, movefocus, d"

      # Move windows with Shift + HJKL
      "$mainMod SHIFT, H, movewindow, l"
      "$mainMod SHIFT, L, movewindow, r"
      "$mainMod SHIFT, K, movewindow, u"
      "$mainMod SHIFT, J, movewindow, d"

      # Switch workspaces (1-10)
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      # Move window to workspace (1-10)
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"

      # Scroll through workspaces
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"
    ];

    # Move/resize windows with mouse
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    # Volume and brightness (repeat on hold)
    bindel = [
      ",XF86AudioRaiseVolume, exec, swayosd-client --monitor DP-2 --output-volume raise"
      ",XF86AudioLowerVolume, exec, swayosd-client --monitor DP-2 --output-volume lower"
      ",XF86AudioMute, exec, swayosd-client --monitor DP-2 --output-volume mute-toggle"
      ",XF86AudioMicMute, exec, swayosd-client --monitor DP-2 --input-volume mute-toggle"
      ",XF86MonBrightnessUp, exec, swayosd-client --monitor DP-2 --brightness raise"
      ",XF86MonBrightnessDown, exec, swayosd-client --monitor DP-2 --brightness lower"
    ];

    # Media keys (works even when locked)
    bindl = [
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];
  };
}
