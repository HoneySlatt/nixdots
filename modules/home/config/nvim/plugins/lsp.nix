{
  programs.nixvim.plugins.lsp = {
    enable = true;
    servers = {
      clangd = {
        enable = true;
        cmd = [ "clangd" "--background-index" "--clang-tidy" ];
        filetypes = [ "c" "cpp" "h" "hpp" ];
        rootMarkers = [ "compile_commands.json" "Makefile" ".git" ];
      };
      pyright = {
        enable = true;
        filetypes = [ "python" ];
        rootMarkers = [ "pyproject.toml" "requirements.txt" ".git" ];
      };
      ts_ls = {
        enable = true;
        filetypes = [ "javascript" "javascriptreact" "typescript" "typescriptreact" ];
        rootMarkers = [ "package.json" "tsconfig.json" ".git" ];
      };
      html = {
        enable = true;
        filetypes = [ "html" ];
        rootMarkers = [ "package.json" ".git" ];
      };
      cssls = {
        enable = true;
        filetypes = [ "css" "scss" "less" ];
        rootMarkers = [ "package.json" ".git" ];
      };
    };
  };
}
