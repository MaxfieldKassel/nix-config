{user, ...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      user.name = user.fullName;
      user.email = user.email;

      core.editor = "nvim";
      init.defaultBranch = "main";
      fetch.prune = true;
      pull.rebase = true;
      push.autoSetupRemote = true;
      push.default = "simple";
      rebase.autoStash = true; # pull --rebase works with uncommitted changes
      merge.conflictStyle = "zdiff3"; # conflicts also show the common ancestor
      diff.algorithm = "histogram"; # clearer diffs for moved/changed blocks
      rerere.enabled = true; # reuse a conflict resolution if the same conflict comes back

      alias = {
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
        diffRenderers = [
          {command = "delta --paging=never";}
        ];
      };
    };
  };
}
