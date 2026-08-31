{ pkgs, ... }:

{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.vim-wakatime ];
    extraPackages = [ pkgs.wakatime-cli ];
  };
}
