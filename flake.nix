{
  description = "Cross-Platform System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      mac-app-util,
      ...
    }:
    let
      # Import frequently changed variables
      variables = import ./variables.nix;

      inherit (variables)
        system
        hostName
        userName
        hasHardware
        ;

      # Import the pkgs for the current system
      pkgs = import nixpkgs { inherit system; };

      # Determine the target system for building the docker image.
      # Docker images must be Linux-based, so if we're on macOS, select an appropriate Linux target.
      dockerSystem =
        if
          builtins.elem system [
            "x86_64-linux"
            "aarch64-linux"
          ]
        then
          system
        else if system == "x86_64-darwin" then
          "x86_64-linux"
        else if system == "aarch64-darwin" then
          "aarch64-linux"
        else
          system;

      # Import a set of packages for the docker build, potentially cross-compiling.
      dockerPkgs = if dockerSystem != system then import nixpkgs { system = dockerSystem; } else pkgs;

    in
    {
      # macOS configuration
      darwinConfigurations =
        if system == "aarch64-darwin" || system == "x86_64-darwin" then
          {
            "${hostName}" = nix-darwin.lib.darwinSystem {
              inherit system;
              modules = [
                (
                  { pkgs, ... }:
                  import ./modules/common.nix {
                    inherit pkgs variables;
                  }
                )
                (
                  { config, pkgs, ... }:
                  import ./modules/darwin-specific.nix {
                    inherit
                      config
                      userName
                      pkgs
                      variables
                      ;
                  }
                )
                home-manager.darwinModules.home-manager
                {
                  home-manager.users."${userName}" = {
                    imports = [ ./modules/home.nix ];
                    home.username = userName;
                    home.homeDirectory = "/Users/${userName}";
                  };
                }
                mac-app-util.darwinModules.default # Add mac-app-util module
              ];
            };
          }
        else
          { };

      # Linux configuration
      nixosConfigurations =
        if system == "x86_64-linux" || system == "aarch64-linux" then
          {
            "${hostName}" = nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                (
                  { pkgs, ... }:
                  import ./modules/common.nix {
                    inherit pkgs variables;
                  }
                )

                (
                  { pkgs, ... }:
                  import ./modules/linux-specific.nix {
                    inherit pkgs variables;
                  }
                )
                # Conditionally include hardware-configuration.nix
                (if hasHardware then ./hardware-configuration.nix else null)
                home-manager.nixosModules.home-manager
                {
                  home-manager.users."${userName}" = {
                    imports = [ ./modules/home.nix ];
                    home.username = userName;
                    home.homeDirectory = "/home/${userName}";
                  };
                }
              ];
            };
          }
        else
          { };

      # Docker image build: always build a Docker image targeting Linux.
      dockerImages = {
        "${hostName}-docker" = dockerPkgs.dockerTools.buildImage {
          name = "${hostName}-image";
          tag = "latest";
          # Configure the image as desired (here we simply set a default command).
          config = {
            Cmd = [ "/bin/zsh" ];
          };
        copyToRoot = {
            "/home/${userName}/.config/home-manager" = homeManagerConfig.out;
          };
        };
      };
    };
}
