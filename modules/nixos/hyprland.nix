{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
