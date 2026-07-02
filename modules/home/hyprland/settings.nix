{ ... }:

let
  mkEnv = name: value: { _args = [ name value ]; };
  mkAnim = leaf: speed: { _args = [{ inherit leaf; enabled = true; bezier = "default"; inherit speed; }]; };
in
{
  wayland.windowManager.hyprland.settings = {
    env = [
      (mkEnv "QT_QPA_PLATFORMTHEME" "qt5ct")
      (mkEnv "QT_STYLE_OVERRIDE" "kvantum")
      (mkEnv "XCURSOR_THEME" "phinger-cursors-dark")
      (mkEnv "XCURSOR_SIZE" "24")
      (mkEnv "DXVK_HDR" "1")
      (mkEnv "ENABLE_HDR_WSI" "1")
      (mkEnv "XDG_DATA_DIRS" "/etc/profiles/per-user/honey/share:/run/current-system/sw/share:/usr/local/share:/usr/share")
    ];

    config = {
      general = {
        gaps_in = 6;
        gaps_out = 6;
        border_size = 2;
        col = {
          active_border = "rgba(3a3a3aff)";
          inactive_border = "rgba(1f1f1fff)";
        };
        layout = "dwindle";
      };

      decoration = {
        rounding = 12;
        active_opacity = 1.0;
        inactive_opacity = 0.9;
        shadow = {
          enabled = true;
          range = 30;
          render_power = 5;
          offset = "0 5";
          color = "rgba(00000070)";
        };
      };

      animations = {
        enabled = true;
      };

      dwindle = {
        preserve_split = true;
      };

      scrolling = {
        column_width = 0.5;
        focus_fit_method = 1;
        follow_focus = true;
        explicit_column_widths = "0.333, 0.5, 0.667, 1.0";
        direction = "right";
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        vrr = 2;
      };

      render = {
        cm_auto_hdr = 1;
      };

      xwayland = {
        force_zero_scaling = true;
      };
    };

    animation = [
      (mkAnim "windowsIn" 3)
      (mkAnim "windowsOut" 3)
      (mkAnim "workspaces" 5)
      (mkAnim "windowsMove" 4)
      (mkAnim "fade" 3)
      (mkAnim "border" 3)
    ];
  };
}
