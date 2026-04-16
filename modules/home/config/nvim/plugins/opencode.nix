{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.snacks.enable = true;

    extraPlugins = [
      pkgs.vimPlugins.opencode-nvim
    ];

    extraConfigLua = ''
      vim.g.opencode_opts = {
        server = {
          start = function()
            require("opencode.terminal").open("opencode --port", {
              split = "right",
              width = math.floor(vim.o.columns * 0.25),
            })
          end,
          toggle = function()
            require("opencode.terminal").toggle("opencode --port", {
              split = "right",
              width = math.floor(vim.o.columns * 0.25),
            })
          end,
        },
      }
      vim.o.autoread = true
    '';
  };
}