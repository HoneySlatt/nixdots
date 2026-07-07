{ lib, ... }:

{
  users.users.invidious = {
    isSystemUser = true;
    group = "invidious";
  };
  users.groups.invidious = { };

  services.invidious = {
    enable = true;
    database.createLocally = true;
    port = 3000;

    settings = {
      registration_enabled = false;
    };
  };

  systemd.services.invidious.serviceConfig = {
    DynamicUser = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
