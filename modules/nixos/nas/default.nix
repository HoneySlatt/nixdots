{ ... }:

{
  imports = [
    ./tailscale.nix
    ./jellyfin.nix
    ./servarr.nix
    ./samba.nix
    ./immich.nix
    ./searxng.nix
    ./navidrome.nix
    ./invidious.nix
    ./aiostreams.nix
  ];
}
