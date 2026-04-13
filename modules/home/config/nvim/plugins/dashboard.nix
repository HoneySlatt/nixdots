{ pkgs, ... }:
{
  programs.nixvim.extraPlugins = [ pkgs.vimPlugins.alpha-nvim ];

  programs.nixvim.extraConfigLua = ''
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    local header = {
      type = "text",
      val = {
        "███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗",
        "████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║",
        "██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║",
        "██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║",
        "██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
      },
      opts = { position = "center", hl = "AlphaHeader" },
    }

    local buttons = {
      type = "group",
      val = {
        dashboard.button("f", "  Find file",    ":FzfLua files<CR>"),
        dashboard.button("r", "  Recent files", ":FzfLua oldfiles<CR>"),
        dashboard.button("g", "  Find text",    ":FzfLua live_grep<CR>"),
        dashboard.button("n", "  New file",     ":enew<CR>"),
        dashboard.button("c", "  NixOS config", ":e ~/NixBTW/<CR>"),
        dashboard.button("q", "  Quit",         ":qa<CR>"),
      },
      opts = { spacing = 1 },
    }

    local footer = {
      type = "text",
      val = "Neovim powered by Nix & Honey",
      opts = { position = "center", hl = "AlphaFooter" },
    }

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "alpha",
      callback = function()
        vim.opt.showtabline = 0
        vim.api.nvim_create_autocmd("BufLeave", {
          buffer = 0,
          once = true,
          callback = function()
            vim.opt.showtabline = 2
          end,
        })
      end,
    })

    local function set_hl()
      if vim.g.colors_name == "carbonfox" then
        vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#f2f4f8", bold = true })
      else
        vim.api.nvim_set_hl(0, "AlphaHeader", { link = "Function" })
      end
      vim.api.nvim_set_hl(0, "AlphaButtons",  { link = "Keyword" })
      vim.api.nvim_set_hl(0, "AlphaShortcut", { link = "Type" })
      vim.api.nvim_set_hl(0, "AlphaFooter",   { link = "Comment" })
    end

    set_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        set_hl()
        if vim.bo.filetype == "alpha" then
          alpha.redraw()
        end
      end,
    })

    alpha.setup({
      layout = {
        { type = "padding", val = 2 },
        header,
        { type = "padding", val = 2 },
        buttons,
        { type = "padding", val = 1 },
        footer,
      },
      opts = { margin = 5 },
    })
  '';
}
