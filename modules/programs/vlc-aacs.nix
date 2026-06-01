{
  config,
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

  # libbluray's dl_dlopen tries `libaacs.0.dylib`. macOS Sequoia removed
  # $HOME/lib and /usr/local/lib from dyld's default fallback paths, so we
  # both drop the dylib in $HOME/lib and re-add it to DYLD_FALLBACK_LIBRARY_PATH
  # via a LaunchAgent (which propagates to all GUI apps launched after login).
  home.file."lib/libaacs.0.dylib" = lib.mkIf isDarwin {
    source = "${pkgs.libaacs}/lib/libaacs.0.dylib";
  };
  home.file."lib/libaacs.dylib" = lib.mkIf isDarwin {
    source = "${pkgs.libaacs}/lib/libaacs.dylib";
  };

  launchd.agents.dyld-fallback-lib-path = lib.mkIf isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/launchctl"
        "setenv"
        "DYLD_FALLBACK_LIBRARY_PATH"
        "${config.home.homeDirectory}/lib:/usr/local/lib:/usr/lib"
      ];
      RunAtLoad = true;
      KeepAlive = false;
    };
  };
}
