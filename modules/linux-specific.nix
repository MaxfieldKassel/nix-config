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

  services.docker.enable = true;
}
