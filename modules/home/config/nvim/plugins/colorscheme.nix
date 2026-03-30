{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      rose-pine
      gruvbox-nvim
      nightfox-nvim
      everforest
    ];

    extraConfigLua = ''
      require("catppuccin").setup({
        flavour = "mocha",
        color_overrides = {
          mocha = { blue = "#b4befe" },
        },
        integrations = {
          blink_cmp = true,
          dap = true,
          dap_ui = true,
          gitsigns = true,
          indent_blankline = { enabled = true },
          markdown = true,
          native_lsp = {
            enabled = true,
            underlines = {
              errors = { "undercurl" },
              warnings = { "undercurl" },
              hints = { "undercurl" },
              information = { "undercurl" },
            },
            virtual_text = {
              errors = { "italic" },
              warnings = { "italic" },
              hints = { "italic" },
              information = { "italic" },
            },
          },
          neo_tree = true,
          render_markdown = true,
          treesitter = true,
          which_key = true,
          trouble = true,
          todo_comments = true,
        },
      })

      require("rose-pine").setup({
        variant = "auto",
        dark_variant = "main",
        dim_inactive_windows = false,
        extend_background_behind_borders = true,
        enable = {
          terminal = true,
          legacy_highlights = true,
          migrations = true,
        },
        styles = {
          bold = true,
          italic = true,
          transparency = false,
        },
      })

      require("gruvbox").setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = false,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        contrast = "hard",
        transparent_mode = true,
        dim_inactive = false,
        inverse = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
      })

      require("nightfox").setup({
        options = {
          transparent = false,
          terminal_colors = true,
          dim_inactive = { enabled = false },
          styles = {
            comments = "italic",
            keywords = "bold",
            functions = "italic",
            types = "bold",
          },
          modules = {
            dap = true,
            diagnostic = true,
            gitsigns = true,
            indent_blankline = true,
            native_lsp = true,
            neotree = true,
            treesitter = true,
            whichkey = true,
          },
        },
      })

      vim.g.everforest_background = "medium"
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_diagnostic_text_highlight = 1
      vim.g.everforest_diagnostic_virtual_text = "colored"

      -- Dynamic colorscheme from .current-theme
      local theme_map = {
        catppuccin        = { cs = "catppuccin", bg = "dark"  },
        rosepine          = { cs = "rose-pine",  bg = "dark"  },
        gruvbox           = { cs = "gruvbox",    bg = "dark"  },
        ["gruvbox-light"] = { cs = "gruvbox",    bg = "light" },
        carbonfox         = { cs = "carbonfox",  bg = "dark"  },
        everforest        = { cs = "everforest", bg = "dark"  },
      }

      local f = io.open(vim.fn.expand("~/.config/quickshell/.current-theme"), "r")
      local entry = theme_map["catppuccin"]
      if f then
        local raw = f:read("*l"):gsub("%s+", "")
        f:close()
        entry = theme_map[raw] or entry
      end
      vim.opt.background = entry.bg
      vim.cmd.colorscheme(entry.cs)
    '';
  };
}
