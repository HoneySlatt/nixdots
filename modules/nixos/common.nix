{ ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "cf";

  networking.networkmanager.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  users.users.honey = {
    isNormalUser = true;
    description = "Honey";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "jackaudio" ];
  };

  programs.nano.enable = false;
  programs.dconf.enable = true;
  services.gnome.gnome-keyring.enable = true;

  environment.variables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
  };
}
