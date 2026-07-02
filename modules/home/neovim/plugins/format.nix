{
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          rust       = [ "rustfmt" ];
          go         = [ "goimports" ];
          toml       = [ "taplo" ];
          c          = [ "clang_format" ];
          cpp        = [ "clang_format" ];
          python     = [ "ruff_format" ];
          javascript = [ "prettier" ];
          typescript = [ "prettier" ];
          javascriptreact = [ "prettier" ];
          typescriptreact = [ "prettier" ];
          html       = [ "prettier" ];
          css        = [ "prettier" ];
          json       = [ "prettier" ];
          markdown   = [ "prettier" ];
          lua        = [ "stylua" ];
        };
        format_on_save = {
          timeout_ms = 500;
          lsp_fallback = true;
        };
      };
    };
  };
}
