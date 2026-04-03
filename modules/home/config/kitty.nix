{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    extraConfig = ''
      bold_font        JetBrainsMono NF Bold
      italic_font      JetBrainsMono NF Italic
      bold_italic_font JetBrainsMono NF Medium Italic
      modify_font cell_height 118%
      include /home/honey/.config/kitty/themes/current.conf
    '';

    settings = {
      background_opacity = "0.9";

      shell  = "zsh";
      editor = "nvim";

      allow_remote_control = "yes";
      listen_on            = "unix:@mykitty";

      allow_hyperlinks        = "yes";
      shell_integration       = "enabled";
      confirm_os_window_close = 0;

      cursor_trail                 = 0;
      cursor_trail_decay           = "0.1 0.2";
      cursor_trail_start_threshold = 1;

      wayland_titlebar_color = "system";
    };
  };
}
