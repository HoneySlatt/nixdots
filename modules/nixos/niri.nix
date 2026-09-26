{ inputs, pkgs, ... }:

{
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  environment.systemPackages = [ pkgs.xwayland-satellite ];

  security.pam.services.greetd.enableGnomeKeyring = true;

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
