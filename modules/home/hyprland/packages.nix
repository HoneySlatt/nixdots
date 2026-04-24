{ pkgs, ... }:

{
  home.packages = with pkgs; [
    quickshell
    swaynotificationcenter
    swayosd
    libnotify
    awww
    grim
    imagemagick
    wf-recorder
    wl-clipboard
    hyprpolkitagent
    hyprpicker
    playerctl
  ];
}
