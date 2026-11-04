{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  signingKey = config.programs.git.signing.key;
  # Lists the keys trusted to sign commits, so `git log --show-signature` and `git verify-commit`
  # can check them ("Good signature for <email>").
  allowedSigners = "${config.xdg.configHome}/git/allowed_signers";
in {
  # Written from your public key at each rebuild, since the key itself isn't in this repo.
  home.activation.gitAllowedSigners = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -r ${lib.escapeShellArg signingKey} ]; then
      run mkdir -p ${lib.escapeShellArg (dirOf allowedSigners)}
      run ${pkgs.writeShellScript "write-git-allowed-signers" ''
      printf '%s namespaces="git" %s\n' ${lib.escapeShellArg user.email} "$(cat ${lib.escapeShellArg signingKey})" \
        > ${lib.escapeShellArg allowedSigners}
    ''}
    fi
  '';

  programs.git = {
    enable = true;
    lfs.enable = true;

    # Sign every commit and tag with the SSH key (add the same public key on GitHub as a
    # "Signing key" so commits show as Verified).
    signing = {
      format = "ssh";
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    settings = {
      user.name = user.fullName;
      user.email = user.email;
      gpg.ssh.allowedSignersFile = allowedSigners;

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
    # Same syntax colours as bat, which Stylix themes (modules/theme.nix).
    options.syntax-theme = config.programs.bat.config.theme;
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
