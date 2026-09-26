{ ... }:

{
  programs.niri.settings = {
    environment = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_STYLE_OVERRIDE = "kvantum";
      XCURSOR_THEME = "phinger-cursors-dark";
      XCURSOR_SIZE = "24";
      NIXOS_OZONE_WL = "1";
    };

    cursor = {
      theme = "phinger-cursors-dark";
      size = 24;
    };

    layout = {
      gaps = 6;
      center-focused-column = "never";

      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
        { proportion = 1.0; }
      ];

      default-column-width = { proportion = 0.5; };

      preset-window-heights = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];

      focus-ring = {
        enable = false;
      };

      border = {
        enable = true;
        width = 2;
        active.color = "#3a3a3a";
        inactive.color = "#1f1f1f";
      };

      shadow = {
        enable = true;
        softness = 30;
        spread = 5;
        offset = {
          x = 0;
          y = 5;
        };
        color = "#00000070";
      };
    };

    # Workspaces 1-10 comme sur Hyprland : impairs sur DP-2, pairs sur DP-3.
    workspaces = builtins.listToAttrs (builtins.genList (i:
      let ws = i + 1; in {
        name = if ws < 10 then "0${toString ws}" else toString ws;
        value = {
          name = toString ws;
          open-on-output = if ws / 2 * 2 == ws then "DP-3" else "DP-2";
        };
      }
    ) 10);

    prefer-no-csd = true;

    hotkey-overlay.skip-at-startup = true;

    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
  };
}
