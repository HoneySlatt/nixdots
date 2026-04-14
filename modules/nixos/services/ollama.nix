{ pkgs, ... }:

{
  services.ollama = {
    enable = true;
    openFirewall = true;
    package = pkgs.ollama-rocm;
  };
}