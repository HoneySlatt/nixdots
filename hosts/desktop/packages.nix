{ pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    inputs.millennium.overlays.default
    (final: prev: {
      hackatime-desktop = final.callPackage ../../modules/home/pkgs/hackatime-desktop.nix { };
      steam-metadata-editor = final.callPackage ../../modules/home/pkgs/steam-metadata-editor.nix { };
    })
  ];

  environment.systemPackages = with pkgs; [
    
    # Web Browsers
    firefox
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Desktop Apps
    inputs.kopuz.packages.${pkgs.stdenv.hostPlatform.system}.default
    obs-studio
    blender
    gimp
    inkscape
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
    ryubing
    protonplus
    xivlauncher
    samrewritten
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
    hackatime-desktop
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
