# Command-line tools for the user, installed the same way on every machine.
{pkgs, ...}: {
  home.packages = with pkgs; [
    syncthing
    nix-search

    # To ensure that most operating system behave the same
    # use uutils for all default shell commands.
    # https://github.com/uutils/coreutils
    uutils-coreutils-noprefix

    # Disk usage analyzer with a nice CLI, written in Go
    # https://github.com/dundee/gdu
    gdu

    # Modern `watch` (nixpkgs' procps watch is Linux-only); aliased to `watch` in zsh.nix.
    # https://github.com/sachaos/viddy
    viddy

    # TLDR Replacement written in Rust
    # https://github.com/tldr-pages/tlrc
    tlrc

    # Shell script linter and formatter (Neovim's bash server already runs shellcheck as you type).
    # https://github.com/koalaman/shellcheck
    shellcheck
    shfmt

    # Fastfetch is a replacement for neofetch
    fastfetch

    # Allows for opening dev containers in the cli without vscode.
    # https://containers.dev
    devcontainer

    # A simple program to send files from one computer to another.
    # https://github.com/magic-wormhole/magic-wormhole.rs
    magic-wormhole-rs

    # Runs a speedtest in the CLI
    # https://github.com/sivel/speedtest-cli
    speedtest-cli

    # A graphical ping rewritten in Rust
    # https://github.com/orf/gping
    gping

    # A GUI for managing docker containers
    # https://github.com/jesseduffield/lazydocker
    lazydocker

    # CLI for the Garage S3 server on the NAS, used over RPC (port 30187).
    # Keep the major.minor in step with the TrueNAS app's Garage version.
    # https://garagehq.deuxfleurs.fr
    garage_2

    # Pretty fancy and modern terminal file manager
    # https://github.com/yorukot/superfile
    # superfile

    devenv

    claude-code

    # GitHub Copilot CLI is a standalone `copilot` binary, not a gh extension.
    github-copilot-cli
  ];

  # `, <command>` runs any nixpkgs program without installing it, and a command that isn't
  # installed says which package provides it. Uses nix-index-database's prebuilt weekly index.
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.nix-index-database.comma.enable = true;

  programs.bat = {
    enable = true;
    # batman: man pages with colour (aliased to `man` in zsh.nix); run bare to pick a page with fzf.
    # batgrep: ripgrep results shown through bat, with highlighting and context.
    extraPackages = with pkgs.bat-extras; [batman batgrep];
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    colors = "always";
    icons = "always";
    git = true;
    extraOptions = ["-h"];
  };

  # zoxide replaces `cd` itself (and adds `cdi` for the fzf picker), so completion works too.
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };

  # Keeps zsh (and oh-my-posh) inside `nix-shell` and `nix develop`, without breaking `--run`.
  programs.nix-your-shell = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = ["--disable-up-arrow"];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    # Let Atuin (the history manager) own Ctrl-R; disable fzf's history widget.
    historyWidget.zsh.command = "";
  };

  programs.ripgrep = {
    enable = true;
  };

  programs.gh = {
    enable = true;
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
    silent = true; # Do not print loading messages
  };
}
