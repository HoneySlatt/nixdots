{ pkgs, config, ... }:

{
  imports = [
    ./common.nix
    ./hyprland
    ./config
  ];

  home.packages = [ pkgs.pwasio ];

  xdg.configFile."quickshell".source = config.lib.file.mkOutOfStoreSymlink "/home/honey/NixOS/modules/home/quickshell";
}
