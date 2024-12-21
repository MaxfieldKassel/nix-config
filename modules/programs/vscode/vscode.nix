{ pkgs }:
{
  programs.vscode = {

    enable = true;

    # Add Nix-related extensions
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix # Basic Nix syntax highlighting
      brettm12345.nixfmt-vscode # Formatting for Nix files
    ];

    # VSCode settings
    userSettings = {
      "editor.formatOnSave" = true;
      "editor.defaultFormatter" = "brettm12345.nixfmt-vscode";
      "nix.enableLanguageServer" = true;
      "nixpkgs.autoInstallLSP" = true;
      # Turn on autosave
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 10; # Delay in milliseconds
      # Set terminal to hack nerd font
      "terminal.integrated.fontFamily" = "Hack Nerd Font";
    };

    # Optional: Add global snippets for common Nix options
    globalSnippets = {
      nix = {
        "Nix Option Example" = {
          "prefix" = "nixOption";
          "body" = ''
            option = {
              description = "$1";
              type = "$2";
              default = "$3";
            };'';
          "description" = "Template for defining a Nix option.";
        };
      };
    };
  };
}
