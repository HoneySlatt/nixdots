{
  programs.nixvim.plugins.lsp.servers.emmet_language_server = {
    enable = true;
    filetypes = [ "html" "css" "scss" "javascriptreact" "typescriptreact" ];
  };
}
