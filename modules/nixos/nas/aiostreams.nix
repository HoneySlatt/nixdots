{ ... }:

{
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.aiostreams = {
    image = "ghcr.io/viren070/aiostreams:latest";
    ports = [ "3002:3000" ];
    volumes = [ "/NAS/AIOStreams:/app/data" ];
    # Must contain SECRET_KEY (openssl rand -hex 32), never change it afterwards
    environmentFiles = [ "/etc/aiostreams.env" ];
    environment = {
      BASE_URL = "http://nixbtw.tail9ddd3d.ts.net:3002";
      DATABASE_URI = "sqlite://./data/db.sqlite";
    };
  };

  systemd.tmpfiles.rules = [
    "d /NAS/AIOStreams 0755 root root -"
  ];

  systemd.services.podman-aiostreams.unitConfig.RequiresMountsFor = [ "/NAS" ];

  networking.firewall.allowedTCPPorts = [ 3002 ];
}
