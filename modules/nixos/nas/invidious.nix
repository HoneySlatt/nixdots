{ ... }:

{
  services.invidious = {
    enable = true;
    database.createLocally = true;
    port = 3000;

    settings = {
      registration_enabled = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
