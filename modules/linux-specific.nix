{ pkgs, userName, ... }:

{
  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "wheel"
    ];
    home = "/home/${userName}";
    shell = pkgs.zsh;
  };

  environment.systemPackages = [
    pkgs.libreoffice
  ];

  services.docker.enable = true;
}
