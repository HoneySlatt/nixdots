{ pkgs, ... }:

{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      claude-code-nvim
      codex-nvim
    ];

    extraConfigLua = ''
      require("claude-code").setup({
        command = "${pkgs.claude-code}/bin/claude",
        window = {
          position = "vertical",
          split_ratio = 0.3,
        },
        keymaps = {
          toggle = {
            normal = false,
            terminal = false,
            variants = {
              continue = false,
              verbose = false,
            },
          },
          window_navigation = false,
        },
      })

      require("codex").setup({
        autoinstall = false,
        panel = true,
        keymaps = {
          toggle = nil,
        },
      })
    '';
  };
}
