{ pkgs, variables, ... }:

let
  hasGUI = !variables.isHeadless;
in
{
  # Define the user
  users.users.${variables.userName} = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "wheel"
      "networkmanager"
    ];
    home = "/home/${variables.userName}";
    description = "${variables.description}";

    shell = pkgs.zsh;

    # Need to ignore shell program check because zsh is not
    # found sometimes when building from scratch, although a restart
    # of the machine after runnnig nixos-rebuild switch fixes it.
    ignoreShellProgramCheck = true;
  };

  # Packages to install (linux specific)
  environment.systemPackages = with pkgs; [
    libreoffice
    whatsapp-for-linux
  ];


  # System hostname
  networking.hostName = variables.hostName;

  # Bootloader configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Enable network manager
  networking.networkmanager.enable = true;

  # Timezone and locale
  time.timeZone = variables.timeZone;
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

  # Conditional GUI configuration
  services.xserver.enable = hasGUI;
  services.xserver.displayManager.gdm.enable = hasGUI;
  services.xserver.desktopManager.gnome.enable = hasGUI;

  # Conditional X11 keymap
  services.xserver.xkb =
    if hasGUI then
      {
        layout = "us";
        variant = "";
      }
    else
      null;

  # Conditional printing service
  services.printing.enable = hasGUI;

  # Enable sound only when not in headless mode
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = hasGUI;
  services.pipewire = {
    enable = hasGUI;
    alsa.enable = hasGUI;
    alsa.support32Bit = hasGUI;
    pulse.enable = hasGUI;
  };

  # Virtualization and Docker
  virtualisation.docker.enable = true;
}
