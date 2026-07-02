{ ... }:

{
  programs.niri.settings.window-rules = [
    {
      matches = [ { } ];
      geometry-corner-radius = {
        top-left = 12.0;
        top-right = 12.0;
        bottom-left = 12.0;
        bottom-right = 12.0;
      };
      clip-to-geometry = true;
      opacity = 0.95;
    }
    {
      matches = [ { is-focused = true; } ];
      opacity = 1.0;
    }
    {
      matches = [ { app-id = "^xdg-desktop-portal$"; } ];
      open-floating = true;
    }
    {
      matches = [ { app-id = "^org.pulseaudio.pavucontrol$"; } ];
      open-floating = true;
      default-column-width = { proportion = 0.5; };
      default-window-height = { proportion = 0.5; };
    }
    {
      matches = [ { app-id = "^mpv$"; } ];
      open-fullscreen = true;
    }
    {
      matches = [ { app-id = "^org\\.prismlauncher\\.PrismLauncher$"; } ];
      open-floating = true;
    }
  ];
}
