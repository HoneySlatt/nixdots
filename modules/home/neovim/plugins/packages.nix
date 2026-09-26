{ pkgs, ... }:
{
  programs.nixvim.extraPackages = with pkgs; [
    stylua
    gotools # goimports
    rustfmt
    rust-analyzer
    clang-tools # clang-format
  ];
}
