{
  config,
  pkgs,
  lib,
  ...
}: let
  programNames = [
    "kitty"
    "zsh"
    "git"
    "neovim"
    "vscode"
  ];
  loadConfigs = map (name: import ./programs/${name}/${name}.nix {inherit pkgs;}) programNames;
  mergedPrograms = lib.foldl' (acc: cfg: acc // (cfg.programs or {})) {} loadConfigs;
in {
  home.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;

  programs = mergedPrograms;
}
