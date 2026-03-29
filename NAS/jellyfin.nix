{ ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true; # opens port 8096 (HTTP) and 8920 (HTTPS) locally
  };

  # Allow Jellyfin to use the AMD GPU for hardware transcoding
  users.users.jellyfin.extraGroups = [ "render" "video" ];

  # Media is served from /mnt/NAS — add libraries in the Jellyfin web UI:
  #   Movies  → /mnt/NAS/Movies
  #   Shows   → /mnt/NAS/Shows
  #   Animes  → /mnt/NAS/Animes
}
