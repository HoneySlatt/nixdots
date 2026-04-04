{ pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    inputs.awww.overlays.default
    inputs.millennium.overlays.default
    (final: prev: {
      steam-metadata-editor = final.callPackage ../../modules/home/pkgs/steam-metadata-editor.nix { };
      pwasio = final.callPackage ../../modules/home/pkgs/pwasio.nix { };
      couik = final.callPackage ../../modules/home/pkgs/couik.nix { };
      pomo = final.callPackage ../../modules/home/pkgs/pomo.nix { };
    })
  ];

  environment.systemPackages = with pkgs; [
    # Web Browsers
    firefox
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default

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
    basalt
    zathura
    rustlings
    claude-code
    ani-cli
    trash-cli
    proton-vpn-cli
    protonmail-bridge

    # Others
    jellyfin-mpv-shim
    wineWow64Packages.stagingFull

    # Custom pkgs
    steam-metadata-editor
    couik
    pomo
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    package = pkgs.millennium-steam;
  }; 
}
