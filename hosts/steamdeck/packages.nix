{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Web Browsers
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Desktop Apps
    discord
    protonplus
    moonlight-qt

    # Gaming
    heroic
    xivlauncher

    # TUI/CLI
    git
    codex
    neovim
  ];
}
