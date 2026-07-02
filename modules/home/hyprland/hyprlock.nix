{ ... }:

{
  xdg.configFile."hypr/hyprlock-tui.conf".text = ''
    source = /home/honey/.config/hypr/hyprlock-theme.conf

    general {
      hide_cursor = true
    }

    background {
      monitor = DP-2
      path =
      blur_passes = 0
      color = rgb($hl_background)
    }

    shape {
      monitor = DP-2
      size = 540, 260
      color = rgb($hl_background)
      rounding = 0
      border_size = 2
      border_color = rgb($hl_accent)
      position = 0, 0
      halign = center
      valign = center
    }

    label {
      monitor = DP-2
      text = <span foreground="##$hl_bright">honey@desktop</span><span foreground="##$hl_dim"> :: </span><span foreground="##$hl_accent">hyprlock</span>
      color = rgb($hl_text)
      font_family = IosevkaTerm Nerd Font Mono
      font_size = 13
      position = 0, 90
      halign = center
      valign = center
    }

    shape {
      monitor = DP-2
      size = 500, 1
      color = rgb($hl_dim)
      rounding = 0
      border_size = 0
      position = 0, 78
      halign = center
      valign = center
    }

    label {
      monitor = DP-2
      text = <span foreground="##$hl_text">session locked</span>
      color = rgb($hl_text)
      font_family = IosevkaTerm Nerd Font Mono
      font_size = 18
      position = 0, 48
      halign = center
      valign = center
    }

    label {
      monitor = DP-2
      text = <span foreground="##$hl_dim">enter password to unlock</span>
      color = rgb($hl_dim)
      font_family = IosevkaTerm Nerd Font Mono
      font_size = 12
      position = 0, -58
      halign = center
      valign = center
    }

    input-field {
      monitor = DP-2
      size = 360, 42
      outline_thickness = 2
      dots_size = 0.16
      dots_spacing = 0.22
      dots_center = true
      outer_color = rgb($hl_accent)
      inner_color = rgb($hl_surface)
      font_color = rgb($hl_text)
      fade_on_empty = false
      placeholder_text = <span foreground="##$hl_dim">password</span>
      hide_input = false
      check_color = rgb($hl_bright)
      fail_color = rgb($hl_red)
      fail_text = <span foreground="##$hl_red">auth failed ($ATTEMPTS)</span>
      capslock_color = rgb($hl_yellow)
      position = 0, -20
      halign = center
      valign = center
    }
  '';

  programs.hyprlock = {
    enable = true;
    extraConfig = ''
      source = /home/honey/.config/hypr/hyprlock-theme.conf

      general {
        hide_cursor = true
      }

      background {
        monitor =
        path = $HOME/.config/background
        blur_passes = 0
        color = rgb($hl_background)
      }

      image {
        monitor = DP-2
        path = /home/honey/Pictures/Others/Honey.png
        size = 100
        border_color = rgb($hl_accent)
        position = 0, 75
        halign = center
        valign = center
      }

      input-field {
        monitor = DP-2
        size = 300, 60
        outline_thickness = 4
        dots_size = 0.2
        dots_spacing = 0.2
        dots_center = true
        outer_color = rgb($hl_accent)
        inner_color = rgb($hl_surface)
        font_color = rgb($hl_text)
        fade_on_empty = false
        placeholder_text = <span foreground="##$hl_text"><i>󰌾</i><span foreground="##$hl_accent"></span></span>
        hide_input = false
        check_color = rgb($hl_accent)
        fail_color = rgb($hl_red)
        fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
        capslock_color = rgb($hl_yellow)
        position = 0, -47
        halign = center
        valign = center
      }
    '';
  };
}
