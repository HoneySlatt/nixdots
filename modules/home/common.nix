{ config, pkgs, ... }:

{
  home.username = "honey";
  home.homeDirectory = "/home/honey";
  home.stateVersion = "25.11";

  home.pointerCursor = {
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-dark";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.file."NAS".source = config.lib.file.mkOutOfStoreSymlink "/mnt/NAS";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;
}
