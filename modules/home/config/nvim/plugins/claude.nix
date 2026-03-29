{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.snacks.enable = true;

    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "claudecode-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "coder";
          repo = "claudecode.nvim";
          rev = "432121f0f5b9bda041030d1e9e83b7ba3a93dd8f";
          hash = "sha256-r8hAUpSsr8zNm+av8Mu5oILaTfEsXEnJmkzRmvi9pF8=";
        };
      })
    ];

    extraConfigLua = ''
      require("claudecode").setup({})
    '';
  };
}
