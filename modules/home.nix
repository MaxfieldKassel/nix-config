{lib, ...}: let
  programsDir = ./programs;
  nixFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name) (builtins.readDir programsDir);
in {
  home.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;
  imports = map (name: programsDir + "/${name}") (builtins.attrNames nixFiles);
}
