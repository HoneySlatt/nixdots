{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;
      font-family-bold = "JetBrainsMono Nerd Font Bold";
      font-family-italic = "JetBrainsMono Nerd Font Italic";
      font-family-bold-italic = "JetBrainsMono Nerd Font Medium Italic";
      adjust-cell-height = "18%";

      config-file = "/home/honey/.config/ghostty/themes/current.conf";

      background-opacity = 0.9;

      shell-integration = "zsh";
      confirm-close-surface = false;

      mouse-scroll-multiplier = 0.3;

      window-decoration = true;
    };
  };
}