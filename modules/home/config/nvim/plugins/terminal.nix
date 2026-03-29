{
  programs.nixvim.plugins.toggleterm = {
    enable = true;
    settings = {
      shell = "zsh";
      float_opts = {
        border = "rounded";
      };
    };
  };
}
