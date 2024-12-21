{ config, pkgs, ... }:
let
  kittyConfig = import ./programs/kitty/kitty.nix { inherit pkgs; };
  zshConfig = import ./programs/zsh/zsh.nix { inherit pkgs; };
  gitConfig = import ./programs/git/git.nix { inherit pkgs; };
  neovimConfig = import ./programs/neovim/neovim.nix { inherit pkgs; };
  vscodeConfig = import ./programs/vscode/vscode.nix { inherit pkgs; };
in
{
  # General settings
  home.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;

  # Merge configurations into programs
  programs =
    (kittyConfig.programs or { })
    // (zshConfig.programs or { })
    // (gitConfig.programs or { })
    // (neovimConfig.programs or { })
    // (vscodeConfig.programs or { });
}
