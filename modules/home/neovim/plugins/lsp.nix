{
  programs.nixvim.plugins.lsp = {
    enable = true;

    keymaps = {
      lspBuf = {
        "gd"          = { action = "definition";      desc = "Go to definition"; };
        "gD"          = { action = "declaration";     desc = "Go to declaration"; };
        "gr"          = { action = "references";      desc = "Go to references"; };
        "gi"          = { action = "implementation";  desc = "Go to implementation"; };
        "K"           = { action = "hover";           desc = "Hover documentation"; };
        "<leader>ca"  = { action = "code_action";     desc = "Code action"; };
        "<leader>cr"  = { action = "rename";          desc = "Rename symbol"; };
      };
      diagnostic = {
        "[d"         = { action = "goto_prev";   desc = "Previous diagnostic"; };
        "]d"         = { action = "goto_next";   desc = "Next diagnostic"; };
        "<leader>cd" = { action = "open_float";  desc = "Show diagnostic"; };
      };
    };

    servers = {
      # Rust — handled by rustaceanvim, not here

      # C / C++ (systems programming, Phase 2)
      clangd = {
        enable = true;
        cmd = [ "clangd" "--background-index" "--clang-tidy" ];
        filetypes = [ "c" "cpp" "h" "hpp" ];
        rootMarkers = [ "compile_commands.json" "Makefile" ".git" ];
      };

      # Go (Phase 7 — employability)
      gopls = {
        enable = true;
        filetypes = [ "go" "gomod" "gowork" "gotmpl" ];
        rootMarkers = [ "go.work" "go.mod" ".git" ];
        settings = {
          gopls = {
            analyses = {
              unusedparams = true;
              shadow = true;
            };
            staticcheck = true;
            hints = {
              assignVariableTypes = true;
              compositeLiteralFields = true;
              functionTypeParameters = true;
              parameterNames = true;
              rangeVariableTypes = true;
            };
          };
        };
      };

      # TOML — Cargo.toml, config files
      taplo = {
        enable = true;
        filetypes = [ "toml" ];
        rootMarkers = [ "Cargo.toml" ".git" ];
      };

      # Lua — NixOS config, Neovim config
      lua_ls = {
        enable = true;
        filetypes = [ "lua" ];
        rootMarkers = [ ".luarc.json" ".git" ];
        settings = {
          Lua = {
            runtime.version = "LuaJIT";
            workspace.checkThirdParty = false;
            telemetry.enable = false;
          };
        };
      };

      # Python
      pyright = {
        enable = true;
        filetypes = [ "python" ];
        rootMarkers = [ "pyproject.toml" "requirements.txt" ".git" ];
      };

      # Web
      ts_ls = {
        enable = true;
        filetypes = [ "javascript" "javascriptreact" "typescript" "typescriptreact" ];
        rootMarkers = [ "package.json" "tsconfig.json" ".git" ];
      };
      html = {
        enable = true;
        filetypes = [ "html" ];
        rootMarkers = [ "package.json" ".git" ];
      };
      cssls = {
        enable = true;
        filetypes = [ "css" "scss" "less" ];
        rootMarkers = [ "package.json" ".git" ];
      };
    };
  };
}
