{
  programs.nixvim.plugins.trouble = {
    enable = true;
    settings = {
      modes = {
        diagnostics = {
          auto_close = true;
        };
      };
    };
  };
}
