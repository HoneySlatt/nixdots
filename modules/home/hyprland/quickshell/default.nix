{ config, ... }:

{
  imports = [
    ./packages.nix
    ./scripts.nix
  ];

  xdg.configFile."quickshell" = {
    source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/NixOS/modules/home/hyprland/quickshell/config";
    force = true;
  };

  systemd.user.services.qs-userstyles-server = {
    Unit = {
      Description = "Quickshell UserCSS local server";
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${config.home.profileDirectory}/bin/qs-userstyles-server";
      Restart = "on-failure";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
