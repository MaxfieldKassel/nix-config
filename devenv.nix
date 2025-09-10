{ pkgs
, lib
, config
, ...
}:
{
  git-hooks.enable = true;
  git-hooks.hooks.nixpkgs-fmt.enable = true;
}
