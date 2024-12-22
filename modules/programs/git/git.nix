{ pkgs }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Maxfield Kassel"; # Replace this with your git username
    userEmail = "106034283+MaxfieldKassel@users.noreply.github.com"; # Replace this with your github email
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
