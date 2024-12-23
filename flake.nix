{
  description = "Cross-Platform System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nix-darwin.follows = "nix-darwin";
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
      # Inputs for configuration
      hostName = "Max-Air";
      userName = "maxkassel";
      system = "aarch64-darwin"; # Example: "aarch64-darwin", "x86_64-linux", etc.
    in
    {
      # macOS configuration
      darwinConfigurations =
        if system == "aarch64-darwin" || system == "x86_64-darwin" then
          {
            "${hostName}" = nix-darwin.lib.darwinSystem {
              inherit system;
              modules = [
                ./modules/common.nix
                (
                  { config, pkgs, ... }:
                  import ./modules/darwin-specific.nix {
                    inherit config userName pkgs;
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
                ./modules/common.nix
                ./modules/linux-specific.nix
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
    };
}
