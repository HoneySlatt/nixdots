{ pkgs, ... }:
{
  programs.nixvim.plugins = {
    dap = {
      enable = true;
      adapters = {
        executables = {
          gdb = {
            command = "gdb";
            args = [ "--interpreter=dap" "--eval-command" "set print pretty on" ];
          };
          python = {
            command = "${pkgs.python3Packages.debugpy}/bin/python";
            args = [ "-m" "debugpy.adapter" ];
          };
        };
      };
      configurations = {
        c = [
          {
            name = "Launch";
            type = "gdb";
            request = "launch";
            program.__raw = ''
              function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end
            '';
            cwd = "\${workspaceFolder}";
          }
        ];
        cpp = [
          {
            name = "Launch";
            type = "gdb";
            request = "launch";
            program.__raw = ''
              function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end
            '';
            cwd = "\${workspaceFolder}";
          }
        ];
        rust = [
          {
            name = "Launch";
            type = "gdb";
            request = "launch";
            program.__raw = ''
              function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end
            '';
            cwd = "\${workspaceFolder}";
          }
        ];
        python = [
          {
            name = "Launch file";
            type = "python";
            request = "launch";
            program = "\${file}";
            cwd = "\${workspaceFolder}";
          }
        ];
      };
    };

    dap-ui = {
      enable = true;
    };
  };

  # Auto open/close dap-ui
  programs.nixvim.extraConfigLua = ''
    local dap, dapui = require("dap"), require("dapui")
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
  '';
}
