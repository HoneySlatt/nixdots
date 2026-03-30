{
  programs.nixvim.autoCmd = [
    {
      event = "FileType";
      pattern = "markdown";
      callback.__raw = ''
        function()
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
        end
      '';
    }
    # Native inlay hints (Neovim 0.10+)
    {
      event = "LspAttach";
      callback.__raw = ''
        function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end
      '';
    }
  ];
}
