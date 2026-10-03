{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Web Browsers
    brave-origin

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
    claude-code
  ];
}
