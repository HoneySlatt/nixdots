{
  programs.nixvim.plugins = {
    rustaceanvim = {
      enable = true;
      settings = {
        server = {
          default_settings = {
            rust-analyzer = {
              check = {
                command = "clippy";
                extraArgs = [ "--" "-W" "clippy::pedantic" ];
              };
              cargo = {
                allFeatures = true;
                loadOutDirsFromCheck = true;
              };
              inlayHints = {
                bindingModeHints.enable = false;
                chainingHints.enable = true;
                closingBraceHints.enable = true;
                closureReturnTypeHints.enable = "always";
                parameterHints.enable = true;
                typeHints.enable = true;
                typeHints.hideClosureInitialization = false;
              };
              procMacro = {
                enable = true;
              };
            };
          };
        };
      };
    };

    # Inline crate versions in Cargo.toml
    crates-nvim = {
      enable = true;
      settings = {
        autoload = true;
        autoupdate = true;
        lsp = {
          enabled = true;
          actions = true;
          hover = true;
        };
      };
    };
  };
}
