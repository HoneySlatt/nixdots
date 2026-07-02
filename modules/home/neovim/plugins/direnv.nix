{ pkgs, ... }:
let
  direnv-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "direnv-nvim";
    version = "2025-06-16";
    src = pkgs.fetchFromGitHub {
      owner = "actionshrimp";
      repo = "direnv.nvim";
      rev = "0d2edd378dbdf2c653869772d761ad914219ba9d";
      hash = "sha256-p2im4nUV0n9HQsjCA9oGJvTADfKGlCEr/RYWGlUszuU=";
    };
  };
in
{
  programs.nixvim = {
    extraPlugins = [ direnv-nvim ];

    extraConfigLua = ''
      require("direnv-nvim").setup({
        type = "buffer",
        async = true,
        hook = { msg = nil },
        on_direnv_finished = function()
          for _, client in ipairs(vim.lsp.get_clients()) do
            client:stop()
          end
          vim.cmd("edit!")
        end,
      })
    '';
  };
}
