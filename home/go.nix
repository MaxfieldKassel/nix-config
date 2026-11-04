# Go: toolchain, language server, linter and debugger, plus Neovim and VS Code support.
{pkgs, ...}: {
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

    # `go test` under neotest (\n…), including table-driven subtests.
    plugins.neotest.adapters.golang.enable = true;
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
