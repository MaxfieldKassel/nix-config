{
  config,
  pkgs,
  lib,
  user,
  ...
}: {
  programs.oh-my-posh = {
    enable = true;
    # Themes from: https://ohmyposh.dev/docs/themes
    useTheme = "half-life";
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    defaultKeymap = "emacs"; # Disable vi bindings (which zsh auto-enables when $EDITOR matches *vi*)
    # zprof.enable = true; # Enable this when you want to profile zsh

    # Shell aliases
    shellAliases =
      {
        clr = "clear";
        la = "eza -al";
        l = "eza";
        ls = "eza -a";
        htop = "btop";
        tree = "eza --tree -A --total-size --long --no-time";

        # cdi (from zoxide, see cli.nix) uses fzf to pick a directory to enter.
        ci = "cdi";

        ncdu = "gdu";
        lg = "lazygit";
        gitp = "git push";
        gitm = "git merge";
        gitc = "git commit";
        gitco = "git checkout";
        neofetch = "fastfetch";
        watch = "viddy";
        man = "batman";
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        # The repo path is passed explicitly: NH_FLAKE only reaches shells started after a
        # terminal restart (nix-darwin loads its variables once per terminal session).
        rebuild = "nh darwin switch ${config.home.homeDirectory}/${user.flakeDir}";
      };

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    history = {
      append = true;
      share = false; # Do not share between each terminal. Atuin does this for us anyways.
      ignoreSpace = true;
      ignoreAllDups = true;
      ignoreDups = true;
      size = 50000;
      save = 50000;
    };

    initContent = ''
      # Create a function called 'create' that will create a new directory and enter it,
      # also direnv should be added with a flake from the templates.
      function create() {
          if [ -z "$1" ]; then
              echo "Usage: create <directory>"
              return 1
          fi

          if [ -d "$1" ]; then
              echo "Directory already exists"
              return 1
          fi

          # If any part of the command fails, stop and return an error
          # (ERR_EXIT would close the whole terminal instead).
          setopt LOCAL_OPTIONS ERR_RETURN

          mkdir -p "$1" && cd "$1"

          nix flake new -t "github:nix-community/nix-direnv" .
          nix flake update

          direnv allow
          direnv reload

          echo ".direnv" >> .gitignore

          # Create a basic git repository and add gitignore and commit files.
          git init
          git add .envrc .gitignore flake.nix flake.lock
          git commit -m "Init"
      }

      # `ssh` with no arguments picks a host from ~/.ssh/config with fzf (previewing its
      # resolved settings); with arguments it is plain OpenSSH. `ssh <Tab>` also fuzzy-completes hosts.
      function ssh() {
          if (( $# )); then
              command ssh "$@"
              return
          fi
          local host
          host=$(awk 'tolower($1) == "host" { for (i = 2; i <= NF; i++) if ($i !~ /[*?!]/) print $i }' \
              ~/.ssh/config ~/.ssh/config.d/*(N) 2>/dev/null | sort -u |
              fzf --prompt 'ssh> ' --preview 'command ssh -G {} | grep -E "^(hostname|user|port|identityfile|proxyjump) "') || return
          command ssh "$host"
      }

      # VSCode shell integration
      [[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

      ${builtins.readFile ./zsh/fzf-tab.zsh}
    '';
  };
}
