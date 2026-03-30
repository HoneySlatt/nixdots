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
    cliphist
    hyprpolkitagent
    hyprpicker
    playerctl
  ];
}
