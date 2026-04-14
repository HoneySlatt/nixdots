{ ... }:

{
  services.ollama = {
    enable = true;
    openFirewall = true;
    acceleration = "rocm";
  };
}