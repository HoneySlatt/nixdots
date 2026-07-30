{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    
    # Web Browsers
    firefox
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Desktop Apps
    cider-2
    notesnook
    localsend
    libreoffice

    # Developpement
    git
    rustc
    rustfmt
    rust-analyzer
    cargo
    cargo-edit
    clippy
    nodejs
    gcc
    pkg-config
    cmake

    # Gaming
    protonplus
    prismlauncher

    # TUI/CLI
    fzf
    fd
    bat
    eza
    btop
    ffmpeg
    ripgrep
    cava
    fastfetch
    imv
    codex
    opencode
    trash-cli

    
    # Others
    sqlite
    openssl
    nautilus

    # Discord
    (discord.override {
      withVencord = true;
    })
  ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      package = pkgs.millennium-steam;
  };
}
