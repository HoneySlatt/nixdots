{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware.nix
      ./packages.nix
      ../../modules/nixos/common.nix
      ../../modules/nixos/nas
      ../../modules/nixos/services
      ../../modules/nixos/greetd.nix
      ../../modules/nixos/audio.nix
      ../../modules/nixos/hyprland.nix
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
    kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];
    initrd.kernelModules = [ "amdgpu" ];
  };

  hardware = {
    graphics = {
    enable = true;
    enable32Bit = true;
    };
  };

  networking.hostName = "NixBTW";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  services = {
    xserver.videoDrivers = [ "amdgpu" ];
    libinput.mouse.accelProfile = "flat";
    lact.enable = true;
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "25.11";

}
