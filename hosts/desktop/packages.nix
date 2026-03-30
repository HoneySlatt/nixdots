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
    # Hyprland
    quickshell
    swaynotificationcenter
    swayosd
    libnotify
    awww
    grim
    imagemagick
    wf-recorder
    wl-clipboard
    cliphist
    hyprpolkitagent
    hyprpicker
    playerctl

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
    proton-vpn-cli
    protonmail-bridge
    trash-cli
    ani-cli

    # GTK
    adw-gtk3
    papirus-icon-theme
    glib
    gsettings-desktop-schemas

    # Kvantum
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum

    # Others
    nodejs
    nodePackages.less
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
