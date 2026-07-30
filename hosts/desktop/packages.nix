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
    ladybird
    firefox
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Desktop Apps
    kopuz
    cider-2
    obs-studio
    blender
    gimp
    inkscape
    notesnook
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
    ppsspp
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
