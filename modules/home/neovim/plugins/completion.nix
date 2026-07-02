{
  programs.nixvim.plugins.blink-cmp = {
    enable = true;
    settings = {
      keymap = {
        preset = "default";
      };
      appearance = {
        nerd_font_variant = "mono";
      };
      sources = {
        default = [ "lsp" "path" "snippets" "buffer" ];
      };
      completion = {
        documentation = {
          auto_show = true;
        };
      };
    };
  };
}
