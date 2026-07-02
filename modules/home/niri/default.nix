{ ... }:

{
  imports = [
    ./packages.nix
    ./monitors.nix
    ./input.nix
    ./settings.nix
    ./autostart.nix
    ./keybindings.nix
    ./windowrules.nix
    ./swaylock.nix
    ./swayidle.nix
    ./quickshell
  ];

  services.gnome-keyring.enable = true;
}
