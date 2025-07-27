{ pkgs, variables, ... }:

{
  environment.systemPackages =
    with pkgs;
    [
      docker
      docker-compose
      openvpn
      nixfmt-rfc-style
      home-manager
      zsh-fzf-tab # The other fzf package does not help
      syncthing
      nix-search

      #####################
      ##### CLI Tools #####
      #####################

      # To ensure that most operating system behave the same
      # use uutils for all default shell commands.
      # https://github.com/uutils/coreutils
      uutils-coreutils-noprefix

      # Shows the disk usage in a nice CLI
      # https://dev.yorhel.nl/ncdu
      #? I might switch to a differnet package, as this
      #? one is not written in rust and very open source.
      ncdu

      # TLDR Replacement written in Rust
      # https://github.com/tldr-pages/tlrc
      tlrc

      # Although Neofetch is archived, it is still stable
      # (for now) and should not need updates
      # https://github.com/dylanaraps/neofetch
      neofetch

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
    ]
    ++ (
      if variables.isHeadless then
        [ ]
      else
        [
          # GUI programs
          google-chrome
          gimp
          brave
	  vlc-bin
        ]
    );

  # A list of all nerd fonts are found here:
  # https://www.nerdfonts.com/font-downloads
  # Nerd fonts need to be used to ensure that all
  # symbols are able to be used in the CLI.
  fonts.packages = [ pkgs.nerd-fonts.hack ];
  #! If this changes make sure to change vscode.nix and kitty.nix

  # This is required for programs such as google-chrome and others.
  # If you don't want this, disable this setting and remove all programs
  # that do not allow the nix flake to build.
  nixpkgs.config.allowUnfree = true;
}
