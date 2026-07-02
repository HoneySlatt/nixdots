{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Web Browsers
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default

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
