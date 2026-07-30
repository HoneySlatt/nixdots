{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware.nix
      ./packages.nix
      ../../modules/nixos/common.nix
      ../../modules/nixos/greetd.nix
      ../../modules/nixos/audio.nix
      ../../modules/nixos/niri.nix
    ];

  boot = {
    loader = {
      systemd-boot.enable = false;
      timeout = 1;
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiSupport = true;
        maxGenerations = 5;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware = {
    graphics = {
    enable = true;
    enable32Bit = true;
    };
  };

  networking.hostName = "NixOS";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  services = {
    xserver.videoDrivers = [ "amdgpu" ];
    libinput.mouse.accelProfile = "flat";
  };
  system.stateVersion = "25.11";

}
