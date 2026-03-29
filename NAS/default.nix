{ ... }:

{
  imports = [
    ./mount.nix
    ./tailscale.nix
    ./jellyfin.nix
    ./kavita.nix
    ./samba.nix
    ./immich.nix
  ];
}
