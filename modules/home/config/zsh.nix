{ pkgs, ... }:

{
  home.packages = [ pkgs.zsh ];

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;

    plugins = [
      {
        name = "zsh-autosuggestions";
        src  = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "fast-syntax-highlighting";
        src  = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
    ];

    # Only rebuild completion cache if older than 24 hours
    completionInit = ''
      autoload -Uz compinit
      if [[ -n ''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump(#qN.mh+24) ]]; then
        compinit -d "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
      else
        compinit -C -d "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
      fi
    '';

    initContent = ''
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      ZSH_AUTOSUGGEST_USE_ASYNC=1

      if [[ -o interactive ]] && [[ -z "$NVIM" ]]; then
        fastfetch
      fi
    '';

    sessionVariables = {
      BAT_PAGER = "";
    };

    shellAliases = {
      ls   = "eza";
      ll   = "eza -l";
      la   = "eza -la";
      tree = "eza --tree";
      cat  = "bat";
      grep = "rg";
    };
  };
}
