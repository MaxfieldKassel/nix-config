{
  pkgs,
  lib,
  variables,
  ...
}: let
  # Pinned KEYDB.cfg from the community-maintained mirror. Bump the URL/hash
  # to refresh decryption keys for newer Blu-ray titles.
  keydb = pkgs.fetchurl {
    url = "http://vlc-bluray.whoknowsmy.name/files/KEYDB.cfg";
    hash = "sha256-AdDOJ4CFMm4FPDhfuA3gYAbi2zcySVNUwIi9VWO34l8=";
  };

  isDarwin = lib.hasSuffix "-darwin" variables.system;
  keydbTarget =
    if isDarwin
    then "Library/Preferences/aacs/KEYDB.cfg"
    else ".config/aacs/KEYDB.cfg";
in {
  home.file.${keydbTarget}.source = keydb;

  # libbluray's dl_dlopen tries `libaacs.0.dylib`; dyld's fallback search
  # includes $HOME/lib, so dropping both names there lets VLC find it.
  home.file."lib/libaacs.0.dylib" = lib.mkIf isDarwin {
    source = "${pkgs.libaacs}/lib/libaacs.0.dylib";
  };
  home.file."lib/libaacs.dylib" = lib.mkIf isDarwin {
    source = "${pkgs.libaacs}/lib/libaacs.dylib";
  };
}
