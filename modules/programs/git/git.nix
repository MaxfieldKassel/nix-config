{pkgs}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    delta.enable = true;

    userName = "Maxfield Kassel"; # Replace this with your git username
    userEmail = "106034283+MaxfieldKassel@users.noreply.github.com"; # Replace this with your github email
    extraConfig = {
      core.editor = "nvim";

      init.defaultBranch = "main";
      fetch.prune = true;
      pull.rebase = true;

      push.autoSetupRemote = true;
      push.default = "simple"; # Only push current branch

      alias.co = "checkout";
      alias.b = "branch";
      alias.c = "commit";
      alias.s = "status";
      alias.unstage = "reset HEAD --";
      alias.last = "log -1 HEAD";
      alias.graph = "log --all --graph --oneline --decorate";
      alias.lg = "log --oneline --decorate";
    };
  };

  programs.lazygit = {
    enable = true;
  };
}
