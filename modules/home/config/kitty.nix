{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      modify_font = "cell_height 118%";
      background_opacity = 0.9;
      shell_integration = "enabled";
      confirm_os_window_close = 0;
      wheel_scroll_multiplier = 0.3;
      hide_window_decorations = "no";
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty-{kitty_pid}";
    };
    extraConfig = ''
      include /home/honey/.config/kitty/fonts.conf
      include /home/honey/.config/kitty/theme.conf
    '';
  };
}
