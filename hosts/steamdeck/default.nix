{ inputs, ... }:

{
  imports = [
    ./hardware.nix
    ./packages.nix
    inputs.jovian.nixosModules.default
    ../../modules/nixos/common.nix
    ../../modules/nixos/audio.nix
  ];

  networking.hostName = "steamdeck";

  jovian.devices.steamDeck.enable = true;
  jovian.steam.enable = true;
  jovian.steam.user = "honey";
  jovian.steam.autoStart = true;
  jovian.steam.desktopSession = "plasma";

  programs.gamemode.enable = true;

  services.desktopManager.plasma6.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";
}
