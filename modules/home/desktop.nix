{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./config
    ./zed
    ./neovim
    ./helix
    ./hyprland
    ./hyprland/quickshell
  ];
  home.file."NAS" = {source = config.lib.file.mkOutOfStoreSymlink "/NAS";};
}
