{ ... }:

let
  palettes = {
    kanagawa = {
      bg = "#1F1F28"; bg1 = "#2A2A37"; bg2 = "#363646"; bg3 = "#54546D";
      fg = "#DCD7BA"; fg2 = "#727169";
      red = "#E82424"; green = "#98BB6C"; yellow = "#E6C384";
      blue = "#7E9CD8"; purple = "#957FB8"; aqua = "#6A9589"; orange = "#FFA066";
    };
    kanagawa-lotus = {
      bg = "#F2ECBC"; bg1 = "#E5DDB0"; bg2 = "#DCD5AC"; bg3 = "#DCD7BA";
      fg = "#545464"; fg2 = "#8A8980";
      red = "#C84053"; green = "#6F894E"; yellow = "#DE9800";
      blue = "#4D699B"; purple = "#766B90"; aqua = "#5E857A"; orange = "#CC6D00";
    };
    sakura = {
      bg = "#191719"; bg1 = "#252326"; bg2 = "#2F2B30"; bg3 = "#5A525B";
      fg = "#D6C1C5"; fg2 = "#967E82";
      red = "#C5505E"; green = "#759886"; yellow = "#B0886F";
      blue = "#878FB9"; purple = "#BC8EC6"; aqua = "#A289A1"; orange = "#B46E90";
    };
    onedark = {
      bg = "#282C34"; bg1 = "#21252B"; bg2 = "#2C323C"; bg3 = "#3E4451";
      fg = "#ABB2BF"; fg2 = "#828997";
      red = "#E06C75"; green = "#98C379"; yellow = "#E5C07B";
      blue = "#61AFEF"; purple = "#C678DD"; aqua = "#56B6C2"; orange = "#D19A66";
    };
    tokyonight = {
      bg = "#1A1B26"; bg1 = "#16161E"; bg2 = "#292E42"; bg3 = "#3B4261";
      fg = "#C0CAF5"; fg2 = "#565F89";
      red = "#F7768E"; green = "#9ECE6A"; yellow = "#E0AF68";
      blue = "#7AA2F7"; purple = "#BB9AF7"; aqua = "#73DACA"; orange = "#FF9E64";
    };
    miasma = {
      bg = "#222222"; bg1 = "#1c1c1c"; bg2 = "#383838"; bg3 = "#43492a";
      fg = "#c2c2b0"; fg2 = "#666666";
      red = "#b36d43"; green = "#5f875f"; yellow = "#c9a554";
      blue = "#78824b"; purple = "#bb7744"; aqua = "#c9a554"; orange = "#bb7744";
    };
    catppuccin-mocha = {
      bg = "#1e1e2e"; bg1 = "#181825"; bg2 = "#313244"; bg3 = "#45475a";
      fg = "#cdd6f4"; fg2 = "#a6adc8";
      red = "#f38ba8"; green = "#a6e3a1"; yellow = "#f9e2af";
      blue = "#b4befe"; purple = "#cba6f7"; aqua = "#94e2d5"; orange = "#fab387";
    };
    gruvbox = {
      bg = "#282828"; bg1 = "#3c3836"; bg2 = "#504945"; bg3 = "#665c54";
      fg = "#fbf1c7"; fg2 = "#a89984";
      red = "#fb4934"; green = "#b8bb26"; yellow = "#fabd2f";
      blue = "#83a598"; purple = "#d3869b"; aqua = "#8ec07c"; orange = "#fe8019";
    };
    rose-pine = {
      bg = "#191724"; bg1 = "#1f1d2e"; bg2 = "#26233a"; bg3 = "#6e6a86";
      fg = "#e0def4"; fg2 = "#908caa";
      red = "#eb6f92"; green = "#31748f"; yellow = "#f6c177";
      blue = "#c4a7e7"; purple = "#c4a7e7"; aqua = "#9ccfd8"; orange = "#f6c177";
    };
    everforest = {
      bg = "#2b3339"; bg1 = "#323c41"; bg2 = "#3a4248"; bg3 = "#7a8478";
      fg = "#d3c6aa"; fg2 = "#7a8478";
      red = "#e67e80"; green = "#a7c080"; yellow = "#dbbc7f";
      blue = "#7fbbb3"; purple = "#d699b6"; aqua = "#83c092"; orange = "#e69875";
    };
    carbonfox = {
      bg = "#161616"; bg1 = "#262626"; bg2 = "#393939"; bg3 = "#525252";
      fg = "#f2f4f8"; fg2 = "#525252";
      red = "#ee5396"; green = "#25be6a"; yellow = "#08bdba";
      blue = "#78a9ff"; purple = "#be95ff"; aqua = "#33b1ff"; orange = "#ee5396";
    };
    pastel = {
      bg = "#1A1D23"; bg1 = "#22262E"; bg2 = "#2A2F38"; bg3 = "#5C6370";
      fg = "#C5CDD9"; fg2 = "#5C6370";
      red = "#E06C75"; green = "#98C379"; yellow = "#E5C07B";
      blue = "#61AFEF"; purple = "#C678DD"; aqua = "#56B6C2"; orange = "#E5C07B";
    };
  };

  mkOverride = pal: {
    "editor.background" = pal.bg;
    "editor.foreground" = pal.fg;
    "editor.gutter.background" = pal.bg;
    "editor.line_number" = pal.fg2;
    "editor.active_line_number" = pal.fg;
    "editor.active_line.background" = "${pal.bg1}bf";
    background = pal.bg;
    "status_bar.background" = pal.bg;
    "title_bar.background" = pal.bg;
    "tab_bar.background" = pal.bg;
    "tab.inactive_background" = pal.bg1;
    "panel.background" = pal.bg;
    "toolbar.background" = pal.bg1;
    "terminal.background" = pal.bg;
    "terminal.foreground" = pal.fg;
    "terminal.ansi.black" = pal.bg;
    "terminal.ansi.red" = pal.red;
    "terminal.ansi.green" = pal.green;
    "terminal.ansi.yellow" = pal.yellow;
    "terminal.ansi.blue" = pal.blue;
    "terminal.ansi.magenta" = pal.purple;
    "terminal.ansi.cyan" = pal.aqua;
    "terminal.ansi.white" = pal.fg;
    "terminal.ansi.bright_black" = pal.fg2;
    border = pal.bg1;
    "border.focused" = pal.blue;
    "border.variant" = pal.bg2;
    "scrollbar.thumb.background" = "${pal.fg}4c";
    text = pal.fg;
    "text.muted" = pal.fg2;
    "text.accent" = pal.blue;
    icon = pal.fg;
    "icon.muted" = pal.fg2;
    "icon.accent" = pal.blue;
    "element.background" = pal.bg1;
    "element.hover" = pal.bg2;
    "element.active" = pal.bg3;
    "element.selected" = pal.bg3;
    "surface.background" = pal.bg1;
    "elevated_surface.background" = pal.bg1;
    "syntax" = {
      comment = { color = pal.fg2; font_style = "italic"; };
      string = { color = pal.green; };
      keyword = { color = pal.purple; };
      function = { color = pal.blue; };
      constructor = { color = pal.blue; };
      variable = { color = pal.fg; };
      type = { color = pal.yellow; };
      constant = { color = pal.orange; };
      number = { color = pal.orange; };
      operator = { color = pal.aqua; };
      property = { color = pal.red; };
      attribute = { color = pal.blue; };
      "diff.plus" = { color = pal.green; };
      "diff.minus" = { color = pal.red; };
    };
  };
in
{
  # Deploy palette files for dynamic theme switching
  xdg.configFile = {
    "zed/theme-overrides/kanagawa.json".text = builtins.toJSON (mkOverride palettes.kanagawa);
    "zed/theme-overrides/kanagawa-lotus.json".text = builtins.toJSON (mkOverride palettes.kanagawa-lotus);
    "zed/theme-overrides/sakura.json".text = builtins.toJSON (mkOverride palettes.sakura);
    "zed/theme-overrides/onedark.json".text = builtins.toJSON (mkOverride palettes.onedark);
    "zed/theme-overrides/tokyonight.json".text = builtins.toJSON (mkOverride palettes.tokyonight);
    "zed/theme-overrides/miasma.json".text = builtins.toJSON (mkOverride palettes.miasma);
    "zed/theme-overrides/catppuccin-mocha.json".text = builtins.toJSON (mkOverride palettes.catppuccin-mocha);
    "zed/theme-overrides/gruvbox.json".text = builtins.toJSON (mkOverride palettes.gruvbox);
    "zed/theme-overrides/rosepine.json".text = builtins.toJSON (mkOverride palettes.rose-pine);
    "zed/theme-overrides/everforest.json".text = builtins.toJSON (mkOverride palettes.everforest);
    "zed/theme-overrides/carbonfox.json".text = builtins.toJSON (mkOverride palettes.carbonfox);
    "zed/theme-overrides/pastelglow.json".text = builtins.toJSON (mkOverride palettes.pastel);
  };

  # Use One Dark as base + theme_overrides for dynamic switching
  programs.zed-editor.userSettings.theme_overrides = {
    "One Dark" = mkOverride palettes.gruvbox;
  };
}
