{
  description = "Cross-Platform System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    nixvim,
    ...
  }: let
    lib = nixpkgs.lib;

    # Add a new host by creating hosts/<hostname>.nix and listing it here.
    hosts = {
      "Maxs-MacBook-Air" = import ./hosts/Maxs-MacBook-Air.nix;
    };

    isDarwin = system: lib.hasSuffix "-darwin" system;

    mkDarwinSystem = _hostName: variables:
      nix-darwin.lib.darwinSystem {
        system = variables.system;
        specialArgs = {inherit variables;};
        modules = [
          ./modules/common.nix
          ./modules/darwin-specific.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.extraSpecialArgs = {inherit variables;};
            home-manager.users."${variables.userName}" = {
              imports = [
                ./modules/home.nix
                nixvim.homeModules.nixvim
              ];
              home.username = variables.userName;
              home.homeDirectory = "/Users/${variables.userName}";
            };
          }
        ];
      };

    mkLinuxSystem = _hostName: variables:
      nixpkgs.lib.nixosSystem {
        system = variables.system;
        specialArgs = {inherit variables;};
        modules =
          [
            ./modules/common.nix
            ./modules/linux-specific.nix
          ]
          ++ lib.optional variables.hasHardware ./hardware-configuration.nix
          ++ [
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {inherit variables;};
              home-manager.users."${variables.userName}" = {
                imports = [
                  ./modules/home.nix
                  nixvim.homeModules.nixvim
                ];
                home.username = variables.userName;
                home.homeDirectory = "/home/${variables.userName}";
              };
            }
          ];
      };
  in {
    devShells = let
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    in
      lib.genAttrs systems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            git
            lazygit
            neovim
            ripgrep
            fzf
            bat
            eza
            zoxide
            atuin
            btop
            fastfetch
            claude-code
          ];
          shellHook = ''
            export EDITOR=nvim
            export SHELL=${pkgs.zsh}/bin/zsh
            exec ${pkgs.zsh}/bin/zsh
          '';
        };
      });

    darwinConfigurations =
      lib.mapAttrs mkDarwinSystem
      (lib.filterAttrs (_: v: isDarwin v.system) hosts);

    nixosConfigurations =
      lib.mapAttrs mkLinuxSystem
      (lib.filterAttrs (_: v: !isDarwin v.system) hosts);
  };
}
