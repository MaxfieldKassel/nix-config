# Home-manager entry point. Each program lives in its own file below.
{...}: {
  imports = [
    ./cli.nix
    ./zsh.nix
    ./git.nix
    ./neovim.nix
    ./kitty.nix
    ./vscode.nix
  ];

  home.stateVersion = "25.11";
}
