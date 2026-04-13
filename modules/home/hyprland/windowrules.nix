{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "match:class ^(xdg-desktop-portal)$, float on"
      "match:class ^(org.pulseaudio.pavucontrol)$, float on"
      "match:class ^(org.pulseaudio.pavucontrol)$, size 1500 750"
      "match:class ^(mpv)$, fullscreen on"
      "match:class ^(org\\.prismlauncher\\.PrismLauncher)$, float on"
    ];
  };
}
