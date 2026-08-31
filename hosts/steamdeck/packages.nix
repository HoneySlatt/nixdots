{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Web Browsers
    brave-origin

    # Desktops Apps
    vesktop
    moonlight-qt
    jellyfin-desktop

    # Gaming
    ryubing
    xivlauncher

    # TUI/CLI
    git
    neovim
    opencode
  ];
}
