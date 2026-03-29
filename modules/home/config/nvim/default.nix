{
  imports = [
    ./options.nix
    ./keymaps.nix
    ./autocommands.nix
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
  };
}
