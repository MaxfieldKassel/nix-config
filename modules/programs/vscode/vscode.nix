{ pkgs }:
{
  programs.vscode = {

    enable = true;

    # Add Nix-related extensions
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # Basic Nix syntax highlighting
      # https://marketplace.visualstudio.com/items?itemName=bbenoist.Nix
      bbenoist.nix

      # Nix formatter for vscode
      # https://marketplace.visualstudio.com/items?itemName=brettm12345.nixfmt-vscode
      brettm12345.nixfmt-vscode

      # Color coded comments #! like this!
      # https://marketplace.visualstudio.com/items?itemName=aaron-bond.better-comments
      aaron-bond.better-comments

      # Dev containers for vscode
      # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-containers

      # Direnv for vscode (Needed if using direnv
      # otherwise extensions won't work :()
      # https://github.com/direnv/direnv-vscode
      mkhl.direnv

      # GitLens for vscode
      # https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens
      eamodio.gitlens

      # Vim keybindings for vscode
      # https://marketplace.visualstudio.com/items?itemName=vscodevim.vim
      vscodevim.vim
    ];

    # VSCode settings
    profiles.default.userSettings = {
      "editor.formatOnSave" = true;
      "editor.formatOnPaste" = true;

      # Turn on autosave, use 100 ms as default
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 100; # Delay in milliseconds
      # Set terminal to hack nerd font which is installed in common.nix
      "terminal.integrated.fontFamily" = "Hack Nerd Font";

      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;

      "redhat.telemetry.enabled" = false;
      "workbench.settings.openDefaultSettings" = false;
    };
  };
}
