{ config, pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      "$schema" = "https://opencode.ai/config.json";
      model = "ollama/qwen2.5-coder:14b";
    };
    settings.mcp = {
      fetch = {
        command = "npx";
        args = [ "-y" "@modelcontextprotocol/server-fetch" ];
      };
    };
  };

  home.packages = with pkgs; [
    nodejs
  ];
}
