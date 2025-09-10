{
  pkgs,
  lib,
  config,
  ...
}: {
  git-hooks.enable = true;
  git-hooks.hooks.alejandra.enable = true;
  git-hooks.hooks.no-variables-nix = {
    enable = true;

    name = "Prevent variables.nix";
    entry = "bash -c 'if git diff --cached --name-only | grep -q \"^variables\\.nix$\"; then echo \"❌ Commit rejected: variables.nix must not be added.\"; exit 1; fi'";

    language = "system";
    pass_filenames = false;
  };
}
