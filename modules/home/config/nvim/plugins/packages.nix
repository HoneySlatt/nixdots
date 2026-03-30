{ pkgs, ... }:
{
  programs.nixvim.extraPackages = with pkgs; [
    stylua        # Lua formatter
    gotools       # goimports (Go)
    rustfmt       # Rust formatter
    rust-analyzer # Rust LSP
    clang-tools   # clang-format (C)
  ];
}
