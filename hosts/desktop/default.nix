{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ./packages.nix
    ../../modules/nixos/nas
    ../../modules/nixos/services
    ../../modules/nixos/common.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/ly.nix
    ../../modules/nixos/hyprland.nix
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

  services.libinput.mouse.accelProfile = "flat";
  security.pam.services.ly.enableGnomeKeyring = true;
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

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  users.users.honey.extraGroups = [ "libvirtd" "kvm" ];

  system.stateVersion = "25.11";
}
