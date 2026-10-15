# fzf-tab settings, sourced from home/zsh.nix. fzf-tab itself is loaded as a zsh plugin.

############################################################################
### The following config are dedicated to improving tab usability in zsh ###
############################################################################
# Enable tab completion for hidden files
setopt globdots

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
      application/json)
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

# ----------------------------------------------------
# Kill/ps: show process info when selecting a process
# ----------------------------------------------------
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps -p $word -o command= -ww'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

# -------------------------------------------------------------
# systemctl: show status for systemctl-based completion targets
# -------------------------------------------------------------
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# ---------------------------------------------------
# Parameter expansions, exports, etc.: show their value
# ---------------------------------------------------
zstyle ":fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*" \
  fzf-preview 'echo ${(P)word} | less -F -X'

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
  ) || echo "${(P)word}"
  '

# Use default FZF options if desired
zstyle ":fzf-tab:*" use-fzf-default-opts yes

# Switch group navigation with < and >
zstyle ":fzf-tab:*" switch-group "<" ">"

############################################################################
##################### End of zsh tab config options ########################
############################################################################
