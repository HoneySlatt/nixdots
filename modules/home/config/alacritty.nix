{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      general.import = [
        "/home/honey/.config/alacritty/fonts.toml"
        "/home/honey/.config/alacritty/theme.toml"
      ];
      window = {
        opacity = 0.95;
        decorations = "Full";
      };
      font = {
        offset.y = 3;
      };
      cursor.style.shape = "Block";
    };
  };
}
