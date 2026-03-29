{ pkgs, ... }:

{
  # Required packages
  home.packages = with pkgs; [
    zsh
    atuin
    starship
  ];

  # Zsh configuration
  programs.zsh = {
    enable = true;

    # Plugins
    plugins = [
      {
        name = "zsh-autosuggestions";
        src  = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src  = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];

    # Completion setup
    completionInit = ''
      autoload -Uz compinit
      compinit
    '';

    initContent = ''
      # Case insensitive completion
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # Atuin shell history
      eval "$(atuin init zsh)"

      # Starship prompt
      eval "$(starship init zsh)"

      # Run fastfetch on interactive shells only, skip inside Neovim
      if [[ -o interactive ]] && [[ -z "$NVIM" ]]; then
        fastfetch
      fi
    '';

    # Aliases
    shellAliases = {
      ls   = "eza";
      ll   = "eza -l";
      la   = "eza -la";
      tree = "eza --tree";
    };
  };
}
