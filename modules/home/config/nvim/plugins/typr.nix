{ pkgs, ... }:
let
  volt = pkgs.vimUtils.buildVimPlugin {
    name = "volt";
    src = pkgs.fetchFromGitHub {
      owner = "nvzone";
      repo = "volt";
      rev = "620de1321f275ec9d80028c68d1b88b409c0c8b1";
      hash = "sha256-5Xao1+QXZOvqwCXL6zWpckJPO1LDb8I7wtikMRFQ3Jk=";
    };
  };
  typrSrc = pkgs.fetchFromGitHub {
    owner = "nvzone";
    repo = "typr";
    rev = "584e4ef34dea25a4035627794322f315b22d1253";
    hash = "sha256-PNkoz91RmlZnRrdStAz5b7pGaWv27UOQU/9abYNP/5E=";
  };
  typr = pkgs.runCommand "vimplugin-typr" { } "cp -r ${typrSrc} $out";
in
{
  programs.nixvim = {
    extraPlugins = [ volt typr ];

    extraConfigLua = ''
      require("typr").setup({})
    '';
  };
}
