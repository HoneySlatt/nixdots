{ pkgs, ... }:

let
  tuigreet-theme-wrapper = pkgs.writeShellScriptBin "tuigreet-theme-wrapper" ''
    THEME_FILE=/home/honey/.config/tuigreet/theme.conf
    THEME_ARGS=""
    if [ -f "$THEME_FILE" ]; then
      THEME_ARGS=$(tr '\n' ' ' < "$THEME_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    fi
    exec ${pkgs.tuigreet}/bin/tuigreet \
      --time --remember --remember-session --user-menu --asterisks \
      --greet-align center --greeting 'Welcome back' \
      --theme 'container=#191724;border=#c4a7e7;title=#c4a7e7;greet=#c4a7e7;prompt=#c4a7e7;input=#e0def4;time=#6e6a7f;action=#6e6a7f;button=#9ccfd8;text=#e0def4' \
      $THEME_ARGS \
      --cmd start-hyprland
  '';
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${tuigreet-theme-wrapper}/bin/tuigreet-theme-wrapper";
        user = "honey";
      };
    };
  };

  systemd.services.greetd.serviceConfig.StandardInput = "tty";
  systemd.services.greetd.serviceConfig.StandardOutput = "tty";
  systemd.services.greetd.serviceConfig.TTYPath = "/dev/tty1";
}
