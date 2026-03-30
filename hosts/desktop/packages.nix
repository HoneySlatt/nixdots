{ pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    inputs.awww.overlays.default
    inputs.millennium.overlays.default
    (final: prev: {
      steam-metadata-editor = final.callPackage ./pkgs/steam-metadata-editor.nix { };
      pwasio = final.callPackage ./pkgs/pwasio.nix { };
    })
  ];

  environment.systemPackages = with pkgs; [
    # Web Browsers
    firefox
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Desktop Apps
    cider-2
    vesktop
    zed-editor
    obs-studio
    obsidian
    blender
    gimp
    inkscape
    libreoffice
    qbittorrent
    jellyfin-desktop
    kdePackages.kdenlive

    # Gaming
    ryubing
    xivlauncher
    prismlauncher

    # TUI/CLI
    git
    fzf
    fd
    bat
    eza
    aerc
    btop
    gdu
    cava
    fastfetch
    imv
    zathura
    rustlings
    claude-code
    ani-cli
    trash-cli
    proton-vpn-cli
    protonmail-bridge

    # Others
    ripdrag
    jellyfin-mpv-shim
    wineWow64Packages.stagingFull

    # Custom pkgs
    steam-metadata-editor
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.bigblue-terminal
  ];
}
