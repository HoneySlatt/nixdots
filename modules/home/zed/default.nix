{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./settings.nix
    ./keymaps.nix
    ./languages.nix
    ./themes.nix
    ./debug.nix
  ];

  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "lua"
      "docker-compose"
      "dockerfile"
      "env"
      "git-firefly"
      "make"
      "github-actions"
    ];
  };
}
