# System-level config shared by macOS and NixOS. Personal CLI tools live in home/cli.nix.
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    openvpn
  ];

  # A list of all nerd fonts are found here:
  # https://www.nerdfonts.com/font-downloads
  # Nerd fonts need to be used to ensure that all
  # symbols are able to be used in the CLI.
  fonts.packages = [pkgs.nerd-fonts.hack];
  #! If this changes make sure to change vscode.nix and kitty.nix

  # This is required for programs such as google-chrome and others.
  # If you don't want this, disable this setting and remove all programs
  # that do not allow the nix flake to build.
  nixpkgs.config.allowUnfree = true;
}
