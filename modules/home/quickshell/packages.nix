{ pkgs, ... }:

{
  home.packages = with pkgs; [
    adw-gtk3
    glib
    gsettings-desktop-schemas
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    (writeShellApplication {
      name = "qs-compile-userstyle";
      runtimeInputs = [ nodejs nodePackages.less ];
      text = ''
        NODE_PATH="${nodePackages.less}/lib/node_modules" node "$HOME/.config/quickshell/scripts/compile-userstyle.js" "$@"
      '';
    })
  ];
}
