{ lib, ... }:

let
  companionKey = "z98YxWj0MDvXLzJs";
in
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
    domain = "localhost";

    settings = {
      external_port = 3000;
      https_only = false;
      registration_enabled = true;
      invidious_companion = [ { private_url = "http://127.0.0.1:8282/companion"; } ];
      invidious_companion_key = companionKey;
    };
  };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.invidious-companion = {
    image = "quay.io/invidious/invidious-companion:latest";
    # Bridge network is IPv4-only: YouTube bot-flags the host's IPv6 prefix
    ports = [ "127.0.0.1:8282:8282" ];
    volumes = [ "invidious-companion-cache:/var/tmp/youtubei.js" ];
    environment.SERVER_SECRET_KEY = companionKey;
  };

  systemd.services.invidious.after = [ "podman-invidious-companion.service" ];

  systemd.services.invidious.serviceConfig = {
    DynamicUser = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
