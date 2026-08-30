{ pkgs, ... }:

{
  programs.zed-editor.userSettings.agent_servers = {
    "Claude Code" = {
      type = "custom";
      command = "${pkgs.claude-agent-acp}/bin/claude-agent-acp";
      args = [ ];
      env = { };
    };

    Codex = {
      type = "custom";
      command = "${pkgs.codex-acp}/bin/codex-acp";
      args = [ ];
      env = { };
    };
  };
}
