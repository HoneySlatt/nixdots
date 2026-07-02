{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/70b06a47-bf35-4b98-ae9f-7b9ce09c294e";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/70b06a47-bf35-4b98-ae9f-7b9ce09c294e";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/70b06a47-bf35-4b98-ae9f-7b9ce09c294e";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/70b06a47-bf35-4b98-ae9f-7b9ce09c294e";
      fsType = "btrfs";
      options = [ "subvol=@log" ];
    };

  fileSystems."/.snapshots" =
    { device = "/dev/disk/by-uuid/70b06a47-bf35-4b98-ae9f-7b9ce09c294e";
      fsType = "btrfs";
      options = [ "subvol=@snapshots" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/66D1-EFF2";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/NAS" =
    { device = "/dev/disk/by-uuid/a709dee0-6279-4893-9618-47bb19b61b48";
      fsType = "btrfs";
      options = [ "nofail" "x-systemd.automount" ];
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
