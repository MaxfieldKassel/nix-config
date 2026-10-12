# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a cross-platform Nix flake configuration supporting both macOS (nix-darwin) and NixOS. It manages system settings, macOS defaults, and home-manager configs (dotfiles) for programs like Neovim, Zsh, Git, Kitty, and VSCode.

## Apply Configuration

```bash
# macOS (nix-darwin). Homebrew must be installed first (https://brew.sh); GUI apps are casks.
sudo darwin-rebuild switch --flake .

# NixOS
sudo nixos-rebuild switch --flake .

# Update flake inputs
nix flake update
```

## Development

```bash
# Format all Nix files (alejandra)
nix fmt

# Check flake without applying
nix flake check
```

## Architecture

**`flake.nix`** — Entry point. One `mkSystem` helper builds either a nix-darwin or NixOS system; each machine is one explicit line under `darwinConfigurations` or `nixosConfigurations`. Home-manager runs as a system module with `useGlobalPkgs`, so there is a single nixpkgs instance. The `user` record is passed to every module (system and home) via `specialArgs` / `extraSpecialArgs`.

**`user.nix`** — Username, full name and email of the person these machines belong to.

**`hosts/<hostName>.nix`** — One real module per machine, holding only machine-specific settings: `networking.hostName`, `system.stateVersion`, and on NixOS the bootloader, `hardware-configuration.nix` import, and `../modules/nixos-desktop.nix` if it has a screen. To add a machine, create the file and add a `mkSystem` line in `flake.nix`.

**`modules/shared.nix`** — System-level config for both platforms: Docker/OpenVPN, fonts, `allowUnfree`.

**`modules/darwin.nix`** — macOS-only: Homebrew casks for GUI apps, system defaults (Finder, Dock, screensaver), app settings (Rectangle, Maccy) via `system.defaults.CustomUserPreferences`, Colima launchd agent.

**`modules/nixos.nix`** — NixOS-only base config (user, zsh, flakes, locale, Docker). **`modules/nixos-desktop.nix`** — GNOME, sound, printing and GUI apps; imported by hosts that have a screen.

**`home/default.nix`** — Home-manager entry point; explicitly imports each file in `home/`. To add a program, create `home/<name>.nix` and add it to the imports list.

**`home/cli.nix`** — User CLI packages and small tool configs (eza, fzf, atuin, direnv, …). **`home/zsh.nix`** — Zsh config; fzf-tab completion settings live in `home/zsh/fzf-tab.zsh`.
