{ pkgs, ... }:

{
  home.packages = with pkgs; [
    quickshell
    libnotify
    awww
    grim
    swaynotificationcenter
    brightnessctl
    imagemagick
    wf-recorder
    wl-clipboard
    hyprpolkitagent
    hyprpicker
    hyprsunset
    playerctl
    swayosd
  ];
}
