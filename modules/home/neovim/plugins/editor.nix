{ pkgs, ... }:
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

    # Highlight TODO, FIXME, HACK, NOTE, WARN in code
    todo-comments = {
      enable = true;
      settings = {
        signs = true;
        search = {
          command = "rg";
        };
      };
    };

    # Surround operations: add, change, delete delimiters
    nvim-surround.enable = true;
  };
}
