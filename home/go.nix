# Go: toolchain, language server, linter and debugger, plus Neovim and VS Code support.
{
  lib,
  pkgs,
  ...
}: let
  dapGo.delve.path = lib.getExe pkgs.delve;
in {
  # Installs Go and sets GOPATH (~/go); `go install`ed tools land in ~/go/bin.
  programs.go = {
    enable = true;
    telemetry.mode = "off";
  };

  home.packages = with pkgs; [
    gopls # language server; also used by the VS Code Go extension
    golangci-lint # linter
    delve # debugger (`dlv`)
  ];

  home.sessionPath = ["$HOME/go/bin"];

  programs.nixvim = {
    lsp.servers.gopls = {
      enable = true;
      config.settings.gopls = {
        gofumpt = true;
        staticcheck = true;
        usePlaceholders = true;
        # Shown when type hints are toggled on in Neovim.
        hints = {
          assignVariableTypes = true;
          compositeLiteralFields = true;
          constantValues = true;
          functionTypeParameters = true;
          parameterNames = true;
          rangeVariableTypes = true;
        };
      };
    };

    # \cf: sort/fix imports, then gofumpt (a stricter gofmt).
    plugins.conform-nvim = {
      settings.formatters_by_ft.go = ["goimports" "gofumpt"];
      autoInstall.overrides.goimports = pkgs.gotools;
    };

    plugins.treesitter.grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      go
      gomod
      gosum
      gowork
    ];

    # `go test` under neotest (\n…), including table-driven subtests. It sets dap-go up again
    # for \nd, so it needs the same delve settings.
    plugins.neotest.adapters.golang = {
      enable = true;
      settings.dap_go_opts = dapGo;
    };

    # Debugging with delve (\d…): \dc on a main package, or \nd on a test.
    plugins.dap-go = {
      enable = true;
      settings = dapGo;
    };
  };

  programs.vscode.profiles.default = {
    extensions = [pkgs.vscode-extensions.golang.go];
    userSettings = {
      # Use the gopls installed above instead of letting the extension download tools.
      "go.toolsManagement.autoUpdate" = false;
      "go.useLanguageServer" = true;
    };
  };
}
