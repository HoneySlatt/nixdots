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
    hypridle
    hyprlock
    hyprpicker
    playerctl

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
    mpv
    imv
    jellyfin-desktop
    kdePackages.kdenlive

    # Custom pkgs
    steam-metadata-editor

    # Gaming
    ryubing
    xivlauncher
    prismlauncher

    # TUI/CLI
    kitty
    yazi
    aerc
    btop
    gdu
    cava
    zathura
    claude-code
    proton-vpn-cli
    trash-cli
    ani-cli

    # GTK themes
    (catppuccin-gtk.override { accents = [ "lavender" ]; variant = "mocha"; })
    gruvbox-gtk-theme
    papirus-icon-theme
    glib
    gsettings-desktop-schemas

    # Kvantum
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    (catppuccin-kvantum.overrideAttrs (_: {
      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/Kvantum
        cp -a themes/catppuccin-mocha-lavender $out/share/Kvantum
        runHook postInstall
      '';
    }))
    gruvbox-kvantum
    rose-pine-kvantum

    # Others
    openssl
    nodejs
    nodePackages.less
    git
    lazygit
    fzf
    fd
    bat
    eza
    ripdrag
    fastfetch
    wineWow64Packages.stagingFull
    jellyfin-mpv-shim
    protonmail-bridge
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.bigblue-terminal
  ];
}
