{pkgs, ...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;

    # NEW: put user, core, init, etc. under `settings`
    settings = {
      user.name = "Maxfield Kassel";
      user.email = "106034283+MaxfieldKassel@users.noreply.github.com";

      core.editor = "nvim";
      init.defaultBranch = "main";
      fetch.prune = true;
      pull.rebase = true;
      push.autoSetupRemote = true;
      push.default = "simple";

      aliases = {
        co = "checkout";
        b = "branch";
        c = "commit";
        s = "status";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        graph = "log --all --graph --oneline --decorate";
        lg = "log --oneline --decorate";
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.lazygit = {
    enable = true;
    enableZshIntegration = false;
    settings = {
      git = {
        pagers = [
          {pager = "delta --paging=never";}
        ];
      };
    };
  };
}
