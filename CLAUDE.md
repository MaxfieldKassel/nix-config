# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a cross-platform Nix flake configuration supporting both macOS (nix-darwin) and NixOS. It manages system packages, macOS defaults, and home-manager configs (dotfiles) for programs like Neovim, Zsh, Git, Kitty, and VSCode.

## Apply Configuration

```bash
# macOS (nix-darwin)
darwin-rebuild switch --flake .

# NixOS
sudo nixos-rebuild switch --flake .

# Update flake inputs
nix flake update
```

## Development Environment

```bash
# Enter devenv shell (activates pre-commit hooks and nix LSP)
devenv shell

# Format all Nix files
alejandra .

# Check flake without applying
nix flake check
```

## Architecture

**`hosts/<hostname>.nix`** — One file per machine. Controls `system`, `hostName`, `userName`, `timeZone`, `isHeadless`, and `hasHardware`. To add a new host, create a file here and list it in the `hosts` attrset in `flake.nix`.

**`flake.nix`** — Entry point. Defines the `hosts` attrset and uses `lib.mapAttrs` + `lib.filterAttrs` to build `darwinConfigurations` (suffix `-darwin`) or `nixosConfigurations` (everything else). Host variables are passed to all modules via `specialArgs` / `home-manager.extraSpecialArgs`.

**`modules/common.nix`** — System packages and fonts shared across all platforms.

**`modules/darwin-specific.nix`** — macOS-only: nix-darwin system defaults (Finder, Dock, screensaver), macOS app settings (Rectangle, Maccy) via `activationScripts`, Colima launchd agent, and Darwin-only packages.

**`modules/linux-specific.nix`** — NixOS-only configuration.

**`modules/home.nix`** — Home-manager entry point. Auto-imports every `.nix` file found in `modules/programs/` using `builtins.readDir`. To add a new program, just create a file there.

**`modules/programs/<name>.nix`** — Each program module is a standard home-manager module (receives `pkgs`, `lib`, `variables`, etc.).

## Pre-commit Hooks (via devenv)

- **alejandra** — auto-formats all `.nix` files on commit
