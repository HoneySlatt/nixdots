{ pkgs, ... }:

{
  programs.zed-editor.extraPackages = with pkgs; [
    nil
    nixd
    alejandra
    rust-analyzer
    rustfmt
    gopls
    gotools
    clang-tools
    lua-language-server
    stylua
    pyright
    ruff
    typescript-language-server
    vscode-langservers-extracted
    prettier
    taplo
    lldb
    delve
    python3Packages.debugpy
    emmet-language-server
    dockerfile-language-server
    docker-language-server
    marksman
  ];
}
