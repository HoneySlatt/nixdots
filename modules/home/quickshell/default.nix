{ config, lib, ... }:

{
  imports = [ ./packages.nix ];

  home.activation.quickshell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sfn ${config.home.homeDirectory}/NixOS/modules/home/quickshell ${config.xdg.configHome}/quickshell
  '';
}
