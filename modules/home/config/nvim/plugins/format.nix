{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {
        python = [ "ruff_format" ];
        javascript = [ "prettier" ];
        typescript = [ "prettier" ];
        javascriptreact = [ "prettier" ];
        typescriptreact = [ "prettier" ];
        html = [ "prettier" ];
        css = [ "prettier" ];
        json = [ "prettier" ];
        markdown = [ "prettier" ];
      };
      format_on_save = {
        timeout_ms = 500;
        lsp_fallback = true;
      };
    };
  };
}
