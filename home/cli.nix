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

    # TLDR Replacement written in Rust
    # https://github.com/tldr-pages/tlrc
    tlrc

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

    # Pretty fancy and modern terminal file manager
    # https://github.com/yorukot/superfile
    # superfile

    devenv

    claude-code

    # GitHub Copilot CLI is a standalone `copilot` binary, not a gh extension.
    github-copilot-cli

    # An alternative ssh client with trzsz support
    # https://github.com/trzsz/trzsz-ssh
    trzsz-ssh
  ];

  programs.bat = {
    enable = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    colors = "always";
    icons = "always";
    git = true;
    extraOptions = ["-h"];
  };

  programs.zoxide = {
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
