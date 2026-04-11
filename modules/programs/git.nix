{variables, ...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      user.name = variables.gitName;
      user.email = variables.gitEmail;

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
