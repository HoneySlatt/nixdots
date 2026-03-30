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

  gtk.iconTheme = {
    package = pkgs.papirus-icon-theme;
    name = "Papirus-Dark";
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.bigblue-terminal
  ];

  home.file."NAS".source = config.lib.file.mkOutOfStoreSymlink "/mnt/NAS";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;
}
