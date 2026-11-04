# System-level config shared by macOS and NixOS. Personal CLI tools live in home/cli.nix.
{
  pkgs,
  nixpkgs-garage,
  ...
}: {
  # The garage CLI must match the NAS's Garage version (see flake.nix).
  nixpkgs.overlays = [
    (_final: prev: {
      garage_2 = nixpkgs-garage.legacyPackages.${prev.stdenv.hostPlatform.system}.garage_2;
    })
  ];

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    openvpn
  ];

  # This is required for programs such as google-chrome and others.
  # If you don't want this, disable this setting and remove all programs
  # that do not allow the nix flake to build.
  nixpkgs.config.allowUnfree = true;
}
