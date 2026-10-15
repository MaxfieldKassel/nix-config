# GNOME desktop, sound, printing and GUI apps for NixOS machines with a screen.
# Import it from hosts/<hostName>.nix; headless machines just leave it out.
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    google-chrome
    vlc
    libreoffice
    karere # WhatsApp client (whatsapp-for-linux was removed from nixpkgs)
  ];

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  # Sound via PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
