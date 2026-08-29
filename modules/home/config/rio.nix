{ pkgs, ... }:

{
  programs.rio = {
    enable = true;
    settings = {
      "confirm-before-quit" = false;
      theme = "switch-theme";
      "line-height" = 1.18;
      #window = {
        #opacity = 0.9;
      #};
      fonts = {
        size = 14;
        family = "JetBrainsMono Nerd Font";
      };
      bindings = {
        keys = [
          {
            key = "t";
            "with" = "control | alt";
            action = "CreateTab";
          }
          {
            key = "k";
            "with" = "control | alt | shift";
            action = "MoveDividerUp";
          }
          {
            key = "j";
            "with" = "control | alt | shift";
            action = "MoveDividerDown";
          }
          {
            key = "h";
            "with" = "control | alt | shift";
            action = "MoveDividerLeft";
          }
          {
            key = "l";
            "with" = "control | alt | shift";
            action = "MoveDividerRight";
          }
          {
            key = "j";
            "with" = "control | alt";
            action = "SelectNextSplit";
          }
          {
            key = "k";
            "with" = "control | alt";
            action = "SelectPrevSplit";
          }
        ];
      };
    };
  };
}
