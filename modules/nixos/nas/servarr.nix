{ ... }:

{
  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  users.groups.media = { };

  # Grant access to existing media and inherit it for new files/directories.
  systemd.tmpfiles.rules = [
    "A+ /NAS/Animes - - - - g:media:rwX,d:g:media:rwX"
    "A+ /NAS/Shows - - - - g:media:rwX,d:g:media:rwX"
    "A+ /NAS/Movies - - - - g:media:rwX,d:g:media:rwX"
  ];

  systemd.services.sonarr.unitConfig.RequiresMountsFor = [ "/NAS" ];
  systemd.services.radarr.unitConfig.RequiresMountsFor = [ "/NAS" ];
  systemd.services.bazarr.unitConfig.RequiresMountsFor = [ "/NAS" ];
}
