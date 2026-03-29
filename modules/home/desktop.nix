{ pkgs, config, lib, ... }:

{
  imports = [
    ./common.nix
    ./hyprland
    ./config
  ];

  home.packages = [ pkgs.pwasio ];

  home.activation.quickshell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sfn ${config.home.homeDirectory}/NixOS/modules/home/quickshell ${config.xdg.configHome}/quickshell
  '';
}
