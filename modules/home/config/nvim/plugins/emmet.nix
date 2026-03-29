{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      pkgs.vimPlugins.emmet-vim
    ];
    globals = {
      user_emmet_leader_key = "<C-z>";
    };
  };
}
