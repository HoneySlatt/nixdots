{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    systemd.enable = true;
    settings = {
      adjust-cell-height = "18%";

      config-file = [
        "?/home/honey/.config/ghostty/fonts.conf"
        "?/home/honey/.config/ghostty/themes/current.conf"
      ];

      shell-integration = "zsh";
      confirm-close-surface = false;
      gtk-single-instance = true;
      quit-after-last-window-closed = false;

      mouse-scroll-multiplier = 0.3;

      window-decoration = true;
    };
  };

  xdg.configFile."systemd/user/graphical-session.target.wants/app-com.mitchellh.ghostty.service".source =
    "${pkgs.ghostty}/share/systemd/user/app-com.mitchellh.ghostty.service";
}
