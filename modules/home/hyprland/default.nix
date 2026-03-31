{ ... }:

{
  imports = [
    ./packages.nix
    ./monitors.nix
    ./input.nix
    ./settings.nix
    ./keybindings.nix
    ./autostart.nix
    ./windowrules.nix
    ./scripts.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  programs.hyprland = {
    enable = true;

    settings = {
      # Default programs
      "$terminal" = "kitty";
      "$fileManager" = "yazi";
      "$menu" = "qs msg -c bar toggleLauncher call";

      # Environment variables
      env = [
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "QT_STYLE_OVERRIDE,kvantum"
        "XCURSOR_THEME,phinger-cursors-dark"
        "XCURSOR_SIZE,24"
        "DXVK_HDR,1"
        "ENABLE_HDR_WSI,1"
      ];
    };
  };
}
