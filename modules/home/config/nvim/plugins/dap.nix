{ pkgs, ... }:
{
  programs.nixvim.plugins = {
    dap = {
      enable = true;
      adapters = {
        executables = {
          # Python
          python = {
            command = "${pkgs.python3Packages.debugpy}/bin/python";
            args = [ "-m" "debugpy.adapter" ];
          };
          # Go
          delve = {
            command = "${pkgs.delve}/bin/dlv";
            args = [ "dap" ];
          };
        };
        servers = {
          # Rust & C — codelldb via nixpkgs lldb
          codelldb = {
            port = 13000;
            executable = {
              command = "${pkgs.lldb}/bin/lldb-dap";
              args = [ "--port" "13000" ];
            };
          };
        };
      };
      configurations = {
        rust = [
          {
            name = "Launch binary";
            type = "codelldb";
            request = "launch";
            program.__raw = ''
              function()
                return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
              end
            '';
            cwd = "\${workspaceFolder}";
            stopOnEntry = false;
          }
        ];
        c = [
          {
            name = "Launch binary";
            type = "codelldb";
            request = "launch";
            program.__raw = ''
              function()
                return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
              end
            '';
            cwd = "\${workspaceFolder}";
            stopOnEntry = false;
          }
        ];
        go = [
          {
            name = "Launch file";
            type = "delve";
            request = "launch";
            program = "\${file}";
            cwd = "\${workspaceFolder}";
          }
          {
            name = "Launch package";
            type = "delve";
            request = "launch";
            program = "\${workspaceFolder}";
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

    # Inline variable values during debug sessions
    nvim-dap-virtual-text = {
      enable = true;
    };
  };

  programs.nixvim.extraConfigLua = ''
    local dap, dapui = require("dap"), require("dapui")
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
  '';
}
