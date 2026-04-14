{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./hyprland
    ./quickshell
    ./config
  ];

  home.file."NAS" = {source = config.lib.file.mkOutOfStoreSymlink "/mnt/ssd2";};
}
