{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./config
    ./zed
    ./neovim
    ./niri
    ./niri/quickshell
  ];
}
