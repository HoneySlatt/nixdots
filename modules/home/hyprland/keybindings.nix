{ lib, ... }:

let
  inherit (lib.generators) mkLuaInline;

  luaString = builtins.toJSON;
  bind = key: action: { _args = [ key action ]; };
  bindWith = key: action: options: { _args = [ key action options ]; };

  exec = command: mkLuaInline "hl.dsp.exec_cmd(${luaString command})";
  dispatch = dispatcher: exec "hyprctl dispatch ${dispatcher}";
  focus = direction: mkLuaInline "hl.dsp.focus({ direction = ${luaString direction} })";
  moveWindow = direction: mkLuaInline "hl.dsp.window.move({ direction = ${luaString direction} })";
  workspace = number: mkLuaInline "hl.dsp.focus({ workspace = ${toString number} })";
  workspaceRef = reference: mkLuaInline "hl.dsp.focus({ workspace = ${luaString reference} })";
  moveToWorkspace = number: mkLuaInline "hl.dsp.window.move({ workspace = ${toString number} })";
in
{
  wayland.windowManager.hyprland.settings = {
    bind = [
      # App launchers
      (bind "CTRL + SHIFT + T" (exec "alacritty"))
      (bind "SUPER + Q" (mkLuaInline "hl.dsp.window.close()"))
      (bind "SUPER + E" (exec "alacritty -e yazi"))
      (bind "SUPER + SHIFT + E" (exec "nautilus"))
      (bind "SUPER + V" (mkLuaInline "hl.dsp.window.float({ action = 'toggle' })"))
      (bind "SUPER + SPACE" (exec "toggle-launcher"))
      (bind "SUPER + T" (exec "toggle-theme-launcher"))
      (bind "SUPER + W" (exec "toggle-wallpaper-launcher"))
      (bind "SUPER + G" (exec "toggle-game-launcher"))
      (bind "SUPER + M" (exec "toggle-music-launcher"))
      (bind "SUPER + R" (exec "toggle-power-launcher"))
      (bind "SUPER + TAB" (exec "toggle-overview"))
      (bind "SUPER + B" (exec "helium"))
      (bind "SUPER + SHIFT + B" (exec "firefox"))
      (bind "SUPER + SHIFT + M" (exec "kopuz"))
      (bind "SUPER + SHIFT + T" (exec "toggle-quickshell"))
      (bind "SUPER + SHIFT + W" (exec "toggle-bar-position"))
      (bind "SUPER + SHIFT + V" (exec "toggle-tailscale"))
      (bind "SUPER + CTRL + V" (exec "toggle-vpn-launcher"))
      (bind "SUPER + U" (exec "toggle-nsfw"))
      (bind "SUPER + S" (exec "hyprquickshot-toggle"))
      (bind "SUPER + SHIFT + P" (exec "hyprpicker"))
      (bind "SUPER + D" (exec "discord"))
      (bind "SUPER + SHIFT + D" (exec "element-desktop"))
      (bind "CTRL + SHIFT + M" (exec "tutanota-desktop --no-sandbox %U"))
      (bind "SUPER + CTRL + N" (exec "jellyfin-desktop"))
      (bind "SUPER + SHIFT +G" (exec "steam"))
      (bind "SUPER + F" (mkLuaInline "hl.dsp.window.fullscreen({ mode = 'maximized', action = 'toggle' })"))
      (bind "SUPER + C" (exec "helium --profile-directory=Default --app-id=cadlkienfkclaiaibeoongdcgmdikeeg"))
      (bind "SUPER + SHIFT + C" (exec "alacritty -e codex"))
      (bind "SUPER + CTRL + C" (exec "alacritty -e opencode"))
      (bind "SUPER + N" (exec "alacritty -e nvim"))
      (bind "SUPER + SHIFT + N" (exec "zeditor"))
      (bind "CTRL + ALT + DELETE" (exec "alacritty -e btop"))

      # Move focus with HJKL
      (bind "SUPER + H" (focus "left"))
      (bind "SUPER + L" (focus "right"))
      (bind "SUPER + K" (focus "up"))
      (bind "SUPER + J" (focus "down"))

      # Move windows with Shift + HJKL
      (bind "SUPER + SHIFT + H" (moveWindow "left"))
      (bind "SUPER + SHIFT + L" (moveWindow "right"))
      (bind "SUPER + SHIFT + K" (moveWindow "up"))
      (bind "SUPER + SHIFT + J" (moveWindow "down"))

      # Focus workspace
      (bind "SUPER + 1" (workspace 1))
      (bind "SUPER + 2" (workspace 2))
      (bind "SUPER + 3" (workspace 3))
      (bind "SUPER + 4" (workspace 4))
      (bind "SUPER + 5" (workspace 5))
      (bind "SUPER + 6" (workspace 6))
      (bind "SUPER + 7" (workspace 7))
      (bind "SUPER + 8" (workspace 8))
      (bind "SUPER + 9" (workspace 9))
      (bind "SUPER + 0" (workspace 10))

      # Move window to workspace
      (bind "SUPER + SHIFT + 1" (moveToWorkspace 1))
      (bind "SUPER + SHIFT + 2" (moveToWorkspace 2))
      (bind "SUPER + SHIFT + 3" (moveToWorkspace 3))
      (bind "SUPER + SHIFT + 4" (moveToWorkspace 4))
      (bind "SUPER + SHIFT + 5" (moveToWorkspace 5))
      (bind "SUPER + SHIFT + 6" (moveToWorkspace 6))
      (bind "SUPER + SHIFT + 7" (moveToWorkspace 7))
      (bind "SUPER + SHIFT + 8" (moveToWorkspace 8))
      (bind "SUPER + SHIFT + 9" (moveToWorkspace 9))
      (bind "SUPER + SHIFT + 0" (moveToWorkspace 10))

      # Scroll workspaces up/down (works in both dwindle and scrolling)
      (bind "SUPER + CTRL + J" (mkLuaInline "hl.dsp.focus({ workspace = 'e+1' })"))
      (bind "SUPER + CTRL + K" (mkLuaInline "hl.dsp.focus({ workspace = 'e-1' })"))
      (bind "SUPER + mouse_down" (mkLuaInline "hl.dsp.focus({ workspace = 'e+1' })"))
      (bind "SUPER + mouse_up" (mkLuaInline "hl.dsp.focus({ workspace = 'e-1' })"))

      # Move/resize windows with mouse
      (bindWith "SUPER + mouse:272" (mkLuaInline "hl.dsp.window.drag()") { mouse = true; })
      (bindWith "SUPER + mouse:273" (mkLuaInline "hl.dsp.window.resize()") { mouse = true; })

      # Volume and brightness (repeat on hold, work when locked)
      (bindWith "XF86AudioRaiseVolume" (exec "swayosd-client --monitor DP-2 --output-volume raise") { locked = true; repeating = true; })
      (bindWith "XF86AudioLowerVolume" (exec "swayosd-client --monitor DP-2 --output-volume lower") { locked = true; repeating = true; })
      (bindWith "XF86AudioMute" (exec "swayosd-client --monitor DP-2 --output-volume mute-toggle") { locked = true; repeating = true; })
      (bindWith "XF86AudioMicMute" (exec "swayosd-client --monitor DP-2 --input-volume mute-toggle") { locked = true; repeating = true; })
      (bindWith "XF86MonBrightnessUp" (exec "swayosd-client --monitor DP-2 --brightness raise") { locked = true; repeating = true; })
      (bindWith "XF86MonBrightnessDown" (exec "swayosd-client --monitor DP-2 --brightness lower") { locked = true; repeating = true; })

      # Media keys (work even when locked)
      (bindWith "XF86AudioNext" (exec "playerctl next") { locked = true; })
      (bindWith "XF86AudioPause" (exec "playerctl play-pause") { locked = true; })
      (bindWith "XF86AudioPlay" (exec "playerctl play-pause") { locked = true; })
      (bindWith "XF86AudioPrev" (exec "playerctl previous") { locked = true; })
    ];
  };
}
