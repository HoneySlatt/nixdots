{ ... }:

{
  wayland.windowManager.hyprland.settings = {

    env = [
      "XDG_DATA_DIRS,/etc/profiles/per-user/honey/share:/run/current-system/sw/share:/usr/local/share:/usr/share"
    ];

    # ==================
    # GENERAL LAYOUT
    # ==================
    general = {
      gaps_in = 4;
      gaps_out = 4;
      border_size = 2;
      "col.active_border" = "rgba(c4a7e7ff)";
      "col.inactive_border" = "rgba(26233aff)";
      layout = "dwindle";
    };

    # ==================
    # DECORATION
    # ==================
    decoration = {
      rounding = 0;
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

    # ==================
    # ANIMATIONS
    # ==================
    animations = {
      enabled = true;
      animation = [
        "windowsIn, 1, 3, default"
        "windowsOut, 1, 3, default"
        "workspaces, 1, 5, default"
        "windowsMove, 1, 4, default"
        "fade, 1, 3, default"
        "border, 1, 3, default"
      ];
    };

    # ==================
    # LAYOUTS
    # ==================
    dwindle = {
      preserve_split = true;
    };

    master = {
      mfact = 0.5;
    };

    scrolling = {
      column_width = 0.7;
      fullscreen_on_one_column = true;
      follow_focus = true;
      focus_fit_method = 1;
      follow_min_visible = 0.0;
      explicit_column_widths = "0.333, 0.5, 0.667, 1.0";
    };
    
    # ==================
    # MISC
    # ==================
    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      vrr = 2;
    };

    # ==================
    # RENDER
    # ==================
    render = {
      cm_auto_hdr = 1;
    };

    # ==================
    # XWAYLAND
    # ==================
    xwayland = {
      force_zero_scaling = true;
    };
  };
}
