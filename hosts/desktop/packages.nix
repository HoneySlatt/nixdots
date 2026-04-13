{ pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    inputs.awww.overlays.default
    inputs.millennium.overlays.default
    (final: prev: {
      steam-metadata-editor = final.callPackage ../../modules/home/pkgs/steam-metadata-editor.nix { };
      pwasio = final.callPackage ../../modules/home/pkgs/pwasio.nix { };
    })
  ];

  environment.systemPackages = with pkgs; [
    # Web Browsers
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    librewolf

    # Desktop Apps
    cider-2
    vesktop
    obs-studio
    obsidian
    blender
    gimp
    inkscape
    libreoffice
    qbittorrent
    tutanota-desktop
    jellyfin-desktop
    bitwarden-desktop
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
    ripgrep
    btop
    gdu
    cava
    fastfetch
    imv
    zathura
    rustlings
    opencode
    ani-cli
    trash-cli
    proton-vpn-cli

    # Virtualisation
    virt-manager
    virtio-win

    # Others
    jellyfin-mpv-shim
    wineWow64Packages.stagingFull

    # Custom pkgs
    steam-metadata-editor
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    package = pkgs.millennium-steam;
  }; 
}
