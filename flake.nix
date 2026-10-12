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
    nixpkgs,
    nix-darwin,
    home-manager,
    nixvim,
    ...
  }: let
    lib = nixpkgs.lib;
    user = import ./user.nix;
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

    # Builds a nix-darwin or NixOS system from hosts/<hostName>.nix plus the shared modules.
    mkSystem = hostName: {
      system,
      darwin ? false,
    }:
      (
        if darwin
        then nix-darwin.lib.darwinSystem
        else nixpkgs.lib.nixosSystem
      ) {
        inherit system;
        specialArgs = {inherit user;};
        modules = [
          ./modules/shared.nix
          (
            if darwin
            then ./modules/darwin.nix
            else ./modules/nixos.nix
          )
          ./hosts/${hostName}.nix
          (
            if darwin
            then home-manager.darwinModules.home-manager
            else home-manager.nixosModules.home-manager
          )
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit user;};
              sharedModules = [nixvim.homeModules.nixvim];
              users.${user.name} = import ./home;
            };
          }
        ];
      };
  in {
    # Add a machine by creating hosts/<hostName>.nix and adding a line here.
    darwinConfigurations = {
      "Maxs-MacBook-Air" = mkSystem "Maxs-MacBook-Air" {
        system = "aarch64-darwin";
        darwin = true;
      };
    };

    nixosConfigurations = {
      # "my-nixos-box" = mkSystem "my-nixos-box" {system = "x86_64-linux";};
    };

    # `nix fmt` formats every .nix file in the repo.
    formatter = lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.alejandra);

    devShells = lib.genAttrs systems (system: let
      # claude-code is unfree, so legacyPackages (which disallows unfree) can't be used here.
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
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
          # Only switch to zsh for an interactive `nix develop`, so `nix develop -c <cmd>`
          # and direnv's `use flake` keep working.
          if [[ $- == *i* ]]; then
            exec ${pkgs.zsh}/bin/zsh
          fi
        '';
      };
    });
  };
}
