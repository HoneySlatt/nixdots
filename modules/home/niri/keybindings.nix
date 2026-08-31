{ ... }:

{
  programs.niri.settings.binds = {
    # ── App launchers ────────────────────────────────────────────────────
    "Ctrl+Shift+T".action.spawn = [ "ghostty" "+new-window" ];
    "Mod+Q" = {
      action.close-window = { };
      repeat = false;
    };
    "Mod+E".action.spawn = [ "ghostty" "+new-window" "-e" "yazi" ];
    "Mod+Shift+E".action.spawn = "nautilus";
    "Mod+V".action.toggle-window-floating = { };
    "Mod+Space".action.spawn = "toggle-launcher";
    "Mod+T".action.spawn = "toggle-theme-launcher";
    "Mod+W".action.spawn = "toggle-wallpaper-launcher";
    "Mod+G".action.spawn = "toggle-game-launcher";
    "Mod+M".action.spawn = "toggle-music-launcher";
    "Mod+P".action.spawn = "toggle-power-launcher";
    "Mod+Tab".action.toggle-overview = { };
    "Mod+B".action.spawn = "toggle-browser";
    "Mod+Shift+B".action.spawn = "toggle-secondary-browser";
    "Mod+Shift+M".action.spawn = "kopuz";
    "Mod+Shift+Q".action.spawn = "toggle-quickshell";
    "Mod+Shift+W".action.spawn = "toggle-bar-position";
    "Mod+Shift+V".action.spawn = "toggle-tailscale";
    "Mod+Ctrl+V".action.spawn = "toggle-vpn-launcher";
    "Mod+U".action.spawn = "toggle-nsfw";
    "Mod+S".action.screenshot = { };
    "Mod+Shift+P".action.spawn = "hyprpicker";
    "Mod+D".action.spawn = "discord";
    "Mod+Shift+D".action.spawn = "element-desktop";
    "Ctrl+Shift+M".action.spawn = [ "tutanota-desktop" "--no-sandbox" "%U" ];
    "Mod+Ctrl+N".action.spawn = "jellyfin-desktop";
    "Mod+Shift+G".action.spawn = "steam";
    "Mod+C".action.spawn = [ "ghostty" "+new-window" "-e" "claude" ];
    "Mod+Shift+C".action.spawn = [ "ghostty" "+new-window" "-e" "codex" ];
    "Mod+Ctrl+C".action.spawn = [ "ghostty" "+new-window" "-e" "opencode" ];
    "Mod+N".action.spawn = [ "ghostty" "+new-window" "-e" "nvim" ];
    "Mod+Shift+N".action.spawn = "zeditor";
    "Ctrl+Alt+Delete".action.spawn = [ "ghostty" "+new-window" "-e" "btop" ];

    # ── Focus / Move ─────────────────────────────────────────────────────
    "Mod+H".action.focus-column-left = { };
    "Mod+L".action.focus-column-right = { };
    "Mod+Ctrl+K".action.focus-window-up = { };
    "Mod+Ctrl+J".action.focus-window-down = { };

    "Mod+Shift+H".action.move-column-left = { };
    "Mod+Shift+L".action.move-column-right = { };
    "Mod+Ctrl+Shift+K".action.move-window-up = { };
    "Mod+Ctrl+Shift+J".action.move-window-down = { };

    # ── Monitor ──────────────────────────────────────────────────────────
    "Mod+1".action.focus-monitor-left = { };
    "Mod+2".action.focus-monitor-right = { };
    "Mod+Shift+1".action.move-column-to-monitor-left = { };
    "Mod+Shift+2".action.move-column-to-monitor-right = { };

    # ── Workspaces (scroll infini) ───────────────────────────────────────
    "Mod+K".action.focus-workspace-up = { };
    "Mod+J".action.focus-workspace-down = { };
    "Mod+Shift+K".action.move-column-to-workspace-up = { };
    "Mod+Shift+J".action.move-column-to-workspace-down = { };
    "Mod+WheelScrollDown" = {
      action.focus-workspace-down = { };
      cooldown-ms = 150;
    };
    "Mod+WheelScrollUp" = {
      action.focus-workspace-up = { };
      cooldown-ms = 150;
    };

    # ── Column / window sizing ───────────────────────────────────────────
    "Mod+F".action.maximize-column = { };
    "Mod+R".action.switch-preset-column-width = { };
    "Mod+Shift+R".action.switch-preset-column-width-back = { };
    "Mod+Ctrl+Shift+R".action.switch-preset-window-height = { };
    "Mod+Minus".action.set-column-width = "-10%";
    "Mod+Equal".action.set-column-width = "+10%";
    "Mod+Shift+Minus".action.set-window-height = "-10%";
    "Mod+Shift+Equal".action.set-window-height = "+10%";

    # ── Quit / Lock ─────────────────────────────────────────────────────
    "Mod+Escape".action.spawn = "swaylock";
    "Mod+Shift+Escape" = {
      action.quit = { };
      repeat = false;
    };

    # ── Media / Volume / Brightness ──────────────────────────────────────
    "XF86AudioRaiseVolume" = {
      action.spawn = [ "swayosd-client" "--monitor" "DP-2" "--output-volume" "raise" ];
      allow-when-locked = true;
    };
    "XF86AudioLowerVolume" = {
      action.spawn = [ "swayosd-client" "--monitor" "DP-2" "--output-volume" "lower" ];
      allow-when-locked = true;
    };
    "XF86AudioMute" = {
      action.spawn = [ "swayosd-client" "--monitor" "DP-2" "--output-volume" "mute-toggle" ];
      allow-when-locked = true;
    };
    "XF86AudioMicMute" = {
      action.spawn = [ "swayosd-client" "--monitor" "DP-2" "--input-volume" "mute-toggle" ];
      allow-when-locked = true;
    };
    "XF86MonBrightnessUp" = {
      action.spawn = [ "swayosd-client" "--monitor" "DP-2" "--brightness" "raise" ];
      allow-when-locked = true;
    };
    "XF86MonBrightnessDown" = {
      action.spawn = [ "swayosd-client" "--monitor" "DP-2" "--brightness" "lower" ];
      allow-when-locked = true;
    };

    "XF86AudioNext" = {
      action.spawn = [ "playerctl" "next" ];
      allow-when-locked = true;
    };
    "XF86AudioPause" = {
      action.spawn = [ "playerctl" "play-pause" ];
      allow-when-locked = true;
    };
    "XF86AudioPlay" = {
      action.spawn = [ "playerctl" "play-pause" ];
      allow-when-locked = true;
    };
    "XF86AudioPrev" = {
      action.spawn = [ "playerctl" "previous" ];
      allow-when-locked = true;
    };
  };
}
