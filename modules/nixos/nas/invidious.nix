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

    settings = {
      registration_enabled = false;
      invidious_companion = [ { private_url = "http://127.0.0.1:8282/companion"; } ];
      invidious_companion_key = companionKey;
    };
  };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.invidious-companion = {
    image = "quay.io/invidious/invidious-companion:latest";
    extraOptions = [ "--network=host" ];
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
