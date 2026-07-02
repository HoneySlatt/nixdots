{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jq
    nodejs
    lessc
    netcat-openbsd
    adw-gtk3
    glib
    gsettings-desktop-schemas
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum
  ];
}
