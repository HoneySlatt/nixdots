{ pkgs, ... }:

{
  programs.nixvim.plugins.treesitter = {
    enable = true;

    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      lua
      nix
      python
      go
      rust
      c
      cpp
      javascript
      typescript
      html
      css
      toml
    ];

    settings = {
      highlight.enable = true;

      indent = {
        enable = true;
        disable = [ "python" "html" ];
      };
    };
  };
}
