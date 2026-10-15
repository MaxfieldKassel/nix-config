# NixOS-only system config. Machine-specific settings (bootloader, hostname, stateVersion,
# hardware-configuration.nix) belong in hosts/<hostName>.nix.
{
  pkgs,
  lib,
  user,
  ...
}: {
  # Define the user
  users.users.${user.name} = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "wheel"
      "networkmanager"
    ];
    description = user.fullName;
    shell = pkgs.zsh;
  };

  # Needed for zsh to be a valid login shell (and to set up /etc/zshrc).
  programs.zsh.enable = true;

  # Enable flakes so `nixos-rebuild switch --flake .` keeps working after the first switch
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Enable network manager
  networking.networkmanager.enable = true;

  # Timezone and locale
  time.timeZone = lib.mkDefault "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Virtualization and Docker
  virtualisation.docker.enable = true;
}
