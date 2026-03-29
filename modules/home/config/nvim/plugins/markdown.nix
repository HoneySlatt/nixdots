{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.render-markdown = {
      enable = true;
    };

    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "live-preview-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "brianhuster";
          repo = "live-preview.nvim";
          rev = "c1fcf75c5f9c9c01dd392852de44204b60f1b5b1";
          hash = "sha256-8R4WNFKMz72MoycBK736A5YC8NH1K8TBea2Px4udGZ8=";
        };
        nvimRequireCheck = "livepreview";
      })
    ];
  };
}
