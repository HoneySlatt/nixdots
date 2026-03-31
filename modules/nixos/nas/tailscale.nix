{ ... }:

{
  # Tailscale VPN — remote access to NAS services
  services.tailscale.enable = true;

  # Trust Tailscale interface so services are reachable remotely
  # without opening extra ports on the main firewall
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];

    # Required for Tailscale to function properly
    allowedUDPPorts = [ 41641 ];
  };

  # After rebuild, run once: sudo tailscale up
}
