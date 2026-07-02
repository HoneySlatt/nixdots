{
  programs.nixvim.plugins = {
    web-devicons.enable = true;

    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "auto";
          component_separators = {
            left = "";
            right = "";
          };
          section_separators = {
            left = "";
            right = "";
          };
        };
      };
    };

    neo-tree = {
      enable = true;
      settings = {
        filesystem = {
          follow_current_file = {
            enabled = true;
          };
          filtered_items = {
            visible = true;
          };
        };
      };
    };

    bufferline = {
      enable = true;
      settings = {
        options = {
          diagnostics = "nvim_lsp";
          offsets = [
            {
              filetype = "neo-tree";
              text = "Explorer";
              text_align = "center";
            }
          ];
        };
      };
    };
  };
}
