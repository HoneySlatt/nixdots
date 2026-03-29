{
  programs.nixvim.plugins = {
    nvim-autopairs.enable = true;

    indent-blankline = {
      enable = true;
      settings = {
        indent = {
          char = "│";
        };
        scope = {
          enabled = true;
        };
      };
    };
  };
}
