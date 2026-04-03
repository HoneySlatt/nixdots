{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      (pkgs.vimUtils.buildVimPlugin {
        name = "pastel-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "ankushbhagats";
          repo = "pastel.nvim";
          rev = "67e5aa4a6f70a38a4cc2e814221c9b2f8f354749";
          sha256 = "sha256-+6/HgHjNdiXGA8Zn2MS6gRdSCyV9v5I/bgoCf/wvnmQ=";
        };
      })
      rose-pine
      gruvbox-nvim
      nightfox-nvim
      everforest
    ];

    extraConfigLua = ''
      require("pastel").setup({
        style = {
          transparent = true,
          italic = true,
          bold = true,
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
          transparency = true,
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
          transparent = true,
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


      -- Dynamic colorscheme from .current-theme
      local theme_map = {
        pastelglow        = { cs = "pastelglow", bg = "light" },
        rosepine          = { cs = "rose-pine",  bg = "dark"  },
        gruvbox           = { cs = "gruvbox",    bg = "dark"  },
        ["gruvbox-light"] = { cs = "gruvbox",    bg = "light" },
        carbonfox         = { cs = "carbonfox",  bg = "dark"  },
        everforest        = { cs = "everforest", bg = "dark"  },
      }

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "carbonfox",
        callback = function()
          vim.schedule(function()
            vim.api.nvim_set_hl(0, "Normal",       { bg = "NONE" })
            vim.api.nvim_set_hl(0, "NormalNC",     { bg = "NONE" })
            vim.api.nvim_set_hl(0, "NormalFloat",  { bg = "NONE" })
            vim.api.nvim_set_hl(0, "lualine_a_normal", { fg = "#161616", bg = "#c6c6c6", bold = true })
            vim.api.nvim_set_hl(0, "lualine_b_normal", { fg = "#f2f4f8", bg = "#3a3a3a" })
            vim.api.nvim_set_hl(0, "lualine_y_normal", { fg = "#f2f4f8", bg = "#3a3a3a" })
            vim.api.nvim_set_hl(0, "lualine_z_normal", { fg = "#161616", bg = "#c6c6c6", bold = true })
          end)
        end,
      })

      local f = io.open(vim.fn.expand("~/.config/quickshell/.current-theme"), "r")
      local entry = theme_map["pastelglow"]
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
