{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "match:class ^(xdg-desktop-portal)$, float on"
      "match:class ^(org.pulseaudio.pavucontrol)$, float on"
      "match:class ^(org.pulseaudio.pavucontrol)$, size 1500 750"
      "match:class ^(mpv)$, fullscreen on"
      "match:class ^(org\\.prismlauncher\\.PrismLauncher)$, float on"
      "opacity 1.0 override 1.0 override, match:class ^(helium)$"
      "opacity 1.0 override 1.0 override, match:class ^(librewolf)$"
      "opacity 1.0 override 1.0 override, match:class ^(obsidian|electron)$"
    ];
  };
}
