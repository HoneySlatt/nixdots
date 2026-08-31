{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Web Browsers
    brave-origin

    # Desktops Apps
    discord
    protonplus
    moonlight-qt

    # Gaming
    heroic
    xivlauncher

    # TUI/CLI
    git
    neovim
  ];
}
