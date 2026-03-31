{ ... }:

{
  services.kavita = {
    enable = true;
    tokenKeyFile = "/etc/kavita-token-key";
  };

  # Opens port 5000
  networking.firewall.allowedTCPPorts = [ 5000 ];
}
