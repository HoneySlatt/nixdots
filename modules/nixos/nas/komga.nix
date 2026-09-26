{ ... }:

{
  services.komga = {
    enable = true;
    openFirewall = true;
    settings.server.port = 25600;
  };

  systemd.services.komga.unitConfig.RequiresMountsFor = [ "/NAS" ];
}
