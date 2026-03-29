{ ... }:

{
  services.samba = {
    enable = true;
    openFirewall = true; # opens ports 139 and 445

    settings = {
      global = {
        "workgroup"     = "WORKGROUP";
        "server string" = "NixBTW NAS";
        "security"      = "user";

        # Performance tweaks
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY";
      };

      # Single share exposing the full NAS disk
      # iOS apps (Panels, etc.) can navigate to Mangas/, PDF/, Books/, etc.
      "NAS" = {
        "path"        = "/mnt/NAS";
        "browseable"  = "yes";
        "read only"   = "no";
        "guest ok"    = "no";
        "valid users" = "honey";
      };
    };
  };

  # Required: Samba has its own password store, separate from the system
  # After rebuild, run once: sudo smbpasswd -a honey
}
