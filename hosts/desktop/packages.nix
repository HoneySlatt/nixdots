{ pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    inputs.millennium.overlays.default
    (final: prev: {
      steam-metadata-editor = final.callPackage ../../modules/home/pkgs/steam-metadata-editor.nix { };
    })
  ];

  environment.systemPackages = with pkgs; [
    
    # Web Browsers
    firefox
    brave-origin

    # Desktop Apps
    inputs.kopuz.packages.${pkgs.stdenv.hostPlatform.system}.default
    (pkgs.callPackage ../../modules/home/pkgs/claude-desktop.nix {
      claudeDesktop = inputs.claude-desktop-nix-flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
    })
    obs-studio
    blender
    gimp
    obsidian
    inkscape
    localsend
    libreoffice
    qbittorrent
    element-desktop
    tutanota-desktop
    jellyfin-desktop
    kdePackages.kdenlive

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
    heroic
    xivlauncher
    protonplus
    prismlauncher
    shadps4-qtlauncher

    # TUI/CLI
    gh
    fd
    fzf
    bat
    eza
    gdu
    btop
    ffmpeg
    ripgrep
    cava
    fastfetch
    imv
    concord-tui
    codex
    claude-code
    opencode
    trash-cli

    # Virtualisation
    virt-manager
    virtio-win
    
    # Others
    lact
    sqlite
    openssl
    nautilus
    jellyfin-mpv-shim

    # Custom pkgs
    steam-metadata-editor

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
