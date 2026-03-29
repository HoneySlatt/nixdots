{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../NAS
    ./services/greetd.nix
    ./services/sunshine.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/audio.nix
    ./packages.nix
  ];

  networking.hostName = "NixBTW";

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.hyprland.enable = true;

  services.lact.enable = true;

  # Focusrite low-latency
  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 256;
      "default.clock.min-quantum" = 64;
      "default.clock.max-quantum" = 512;
    };
  };

  services.libinput.mouse.accelProfile = "flat";
  security.pam.services.greetd.enableGnomeKeyring = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    package = pkgs.millennium-steam;
  };

  system.stateVersion = "25.11";
}
