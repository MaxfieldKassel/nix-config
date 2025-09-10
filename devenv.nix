{
  pkgs,
  lib,
  config,
  ...
}: {
  git-hooks.enable = true;
  git-hooks.hooks.alejandra.enable = true;
}
