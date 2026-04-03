{ pkgs, inputs, ... }:

let
  # nodePackages removed from nixpkgs unstable (2026-03-03), pin 24.11 for less
  pkgs-stable = import inputs.nixpkgs-stable { system = pkgs.system; config = {}; overlays = []; };
in
{
  home.packages = with pkgs; [
    adw-gtk3
    glib
    gsettings-desktop-schemas
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    (writeShellApplication {
      name = "qs-compile-userstyle";
      runtimeInputs = [ pkgs.nodejs ];
      text = ''
        NODE_PATH="${pkgs-stable.nodePackages.less}/lib/node_modules" node "$HOME/.config/quickshell/scripts/compile-userstyle.js" "$@"
      '';
    })
  ];
}
