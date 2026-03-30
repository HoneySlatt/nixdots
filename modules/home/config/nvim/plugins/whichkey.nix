{
  programs.nixvim.plugins.which-key = {
    enable = true;
    settings = {
      spec = [
        { __unkeyed-1 = "<leader>a"; group = "AI (Claude)"; }
        { __unkeyed-1 = "<leader>b"; group = "Buffer"; }
        { __unkeyed-1 = "<leader>c"; group = "Code"; }
        { __unkeyed-1 = "<leader>d"; group = "Debug"; }
        { __unkeyed-1 = "<leader>f"; group = "Find"; }
        { __unkeyed-1 = "<leader>g"; group = "Git"; }
        { __unkeyed-1 = "<leader>m"; group = "Markdown"; }
        { __unkeyed-1 = "<leader>t"; group = "Terminal"; }
        { __unkeyed-1 = "<leader>p"; group = "Python"; }
        { __unkeyed-1 = "<leader>x"; group = "Diagnostics"; }
      ];
    };
  };
}
