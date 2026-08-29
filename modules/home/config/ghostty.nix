{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      adjust-cell-height = "18%";

      config-file = [
        "?/home/honey/.config/ghostty/fonts.conf"
        "?/home/honey/.config/ghostty/themes/current.conf"
      ];

      #background-opacity = 0.95;

      shell-integration = "zsh";
      confirm-close-surface = false;
      gtk-single-instance = true;
      quit-after-last-window-closed = false;

      mouse-scroll-multiplier = 0.3;

      window-decoration = true;
    };
  };
}
