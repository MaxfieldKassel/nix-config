{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.docker
    pkgs.docker-compose
    pkgs.google-chrome
    pkgs.signal-desktop
    pkgs.kitty
    pkgs.vscode
    pkgs.openvpn
    pkgs.nixfmt-rfc-style
    pkgs.home-manager
    pkgs.zsh-fzf-tab

    #####################
    ##### CLI Tools #####
    #####################

    # To ensure that most operating system behave the same
    # use uutils for all default shell commands.
    # https://github.com/uutils/coreutils
    pkgs.uutils-coreutils-noprefix

    # Shows the disk usage in a nice CLI
    # https://dev.yorhel.nl/ncdu
    #? I might switch to a differnet package, as this
    #? one is not written in rust and very open source.
    pkgs.ncdu

    # TLDR Replacement written in Rust
    # https://github.com/tldr-pages/tlrc
    pkgs.tlrc

    # Although Neofetch is archived, it is still stable
    # (for now) and should not need updates
    # https://github.com/dylanaraps/neofetch
    pkgs.neofetch
  ];

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
