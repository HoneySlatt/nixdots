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
    ./hyprlock.nix
    ./hypridle.nix
  ];

  services.gnome-keyring.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
  };
}
