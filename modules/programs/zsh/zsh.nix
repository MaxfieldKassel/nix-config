{ pkgs }:
{

  programs.bat = {
    enable = true;
  };

  programs.oh-my-posh = {
    enable = true;
    # Themes from: https://ohmyposh.dev/docs/themes
    useTheme = "half-life";
    enableZshIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    colors = "always";
    icons = "always";
    git = true;
    extraOptions = [ "-h" ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.ripgrep = {
    enable = true;
  };

  programs.thefuck = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.gh = {
    enable = true;
    extensions = [ pkgs.gh-copilot ];
  };

  programs.btop = {
    enable = true;
  };

  programs.lesspipe = {
    enable = true;
  };

  programs.less = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; 
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Shell aliases
    shellAliases = {
      clr = "clear";
      grep = "rg";
      la = "eza -al";
      l = "eza";
      ls = "eza -a";
      htop = "btop";
      tree = "eza --tree -A --total-size --long --no-time";

      # z is a replacement for cd written in rust with some advanced features. 
      cd = "z";

      # zi uses fzf to find a file to enter.
      ci = "zi";

      # Override the nix-shell to use zsh to allow for oh-my-posh to run.
      nix-shell = "nix-shell --run zsh";
    };

    history = {
      append = true;
      share = true;
      ignoreSpace = true;
      ignoreAllDups = true;
      ignoreDups = true;
      size = 50000;
      save = 50000;
    };

    initExtra = ''
      ############################################################################
      ### The following config are dedicated to improving tab usability in zsh ###
      ############################################################################
      # Enable tab completion for hidden files
      setopt globdots

      # Initialize zsh completion
      autoload -U compinit
      compinit

      # Load fzf-tab plugin
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # Disable sorting for `git checkout` completions
      zstyle ":completion:*:git-checkout:*" sort false

      # Set descriptions format for group support in completion
      zstyle ":completion:*:descriptions" format "[%d]"

      # Prevent zsh from showing the default menu, letting fzf-tab handle it
      zstyle ":completion:*" menu no

      # ---------------------------
      # General file/folder preview
      # ---------------------------
      preview_cmd='
        # Print the current file/folder name in bold blue
        printf "\e[1;34m%s\e[0m\n\n" "$realpath"

        if [[ -d $realpath ]]; then
          # Directory preview
          eza -1 --icons --color=always --all "$realpath"
        else
          # Determine MIME type
          filetype=$(file -b --mime-type "$realpath" 2>/dev/null || echo "")
          case "$filetype" in
            text/*)
              # Text file: display using bat
              bat --color=always --style=plain --line-range=:500 "$realpath"
              ;;
            JSON/*)
              # JSON file: also display with bat
              bat --color=always --style=plain --line-range=:500 "$realpath"
              ;;
            *)
              # Fallback: show file info
              file "$realpath"
              ;;
          esac
        fi
      '

      # Apply file/folder preview for these commands
      zstyle ":fzf-tab:complete:(z|cd|eza|bat|cat|ls|grep|rg):*" fzf-preview "$preview_cmd"

      # ---------------------------------------
      # Git checkout: show branches + commits
      # ---------------------------------------
      zstyle ":fzf-tab:complete:git-checkout:*" fzf-preview '
        current_item="$realpath"

        # If a branch is selected, show the five most recent commits
        if git branch --color=always | grep -qE "^\*? *$current_item$"; then
          printf "\e[1;34mRecent commits on %s:\e[0m\n\n" "$current_item"
          git log --oneline -n 5 "$current_item"
        fi
      '

      # ----------------------------------------------------
      # Kill/ps: show process info when selecting a process
      # ----------------------------------------------------
      zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
      zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
        '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
      zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

      # -------------------------------------------------------------
      # systemctl: show status for systemctl-based completion targets
      # -------------------------------------------------------------
      zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

      # ---------------------------------------------------
      # Parameter expansions, exports, etc.: show their value
      # ---------------------------------------------------
      zstyle ":fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*" \
        fzf-preview 'echo ''${(P)word} | less -F -X'

      # ------------------------------------------------------------
      # Set basic fzf flags (key bindings, preview window placement)
      # ------------------------------------------------------------
      zstyle ":fzf-tab:*" fzf-flags \
        --bind=tab:accept \
        --min-height=10 \
        --preview-window=right:60%

      # -------------------------------------------------------------
      # Git extras: show diffs, logs, man pages, etc. with color/delta
      # -------------------------------------------------------------
      zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
        'git diff $word | delta'
      zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
        'git log --color=always $word'
      zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
        'git help $word | bat -plman --color=always'
      zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
        'case "$group" in
          "commit tag") git show --color=always $word ;;
          *) git show --color=always $word | delta ;;
        esac'
      zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
        'case "$group" in
          "modified file") git diff $word | delta ;;
          "recent commit object name") git show --color=always $word | delta ;;
          *) git log --color=always $word ;;
        esac'

      # ----------------------------------------------------------------
      # Commands completion: display tldr/man or location via "which"
      # ----------------------------------------------------------------
      zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
        '(
          out=$(tldr --color always "$word" 2>/dev/null) && echo "$out"
        ) || (
          out=$(MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word" 2>/dev/null) && echo "$out"
        ) || (
          out=$(which "$word" 2>/dev/null) && echo "$out"
        ) || echo "''${(P)word}" 
        '

      # Use default FZF options if desired
      zstyle ":fzf-tab:*" use-fzf-default-opts yes

      # Switch group navigation with < and >
      zstyle ":fzf-tab:*" switch-group "<" ">"

      ############################################################################
      ##################### End of zsh tab config options ########################
      ############################################################################
    '';
  };
}
