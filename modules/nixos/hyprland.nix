{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "start-hyprland";
        user = "honey";
      };
    };
  };

  # suppress the "login:" console output on VT1
  systemd.services.greetd.serviceConfig.StandardInput = "tty";
  systemd.services.greetd.serviceConfig.StandardOutput = "tty";
  systemd.services.greetd.serviceConfig.TTYPath = "/dev/tty1";
}
