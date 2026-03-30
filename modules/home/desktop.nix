{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./hyprland
    ./quickshell
    ./config
  ];

  home.packages = [ pkgs.pwasio ];
}
