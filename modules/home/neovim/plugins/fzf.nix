{
  programs.nixvim.plugins.fzf-lua = {
    enable = true;
    settings = {
      winopts = {
        height = 0.85;
        width = 0.80;
        preview = {
          layout = "vertical";
        };
      };
    };
  };
}
