{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.snacks.enable = true;

    extraPlugins = [
      pkgs.vimPlugins.opencode-nvim
    ];

    extraConfigLua = ''
      vim.g.opencode_opts = {}
      vim.o.autoread = true
    '';
  };
}