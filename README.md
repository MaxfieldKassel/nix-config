# nix-config

My macOS (nix-darwin) and NixOS configuration: system settings, apps, and dotfiles for zsh, Neovim, git, kitty, VS Code and the CLI tools I use, all managed by a single Nix flake with home-manager.

## Set up a new Mac

1. **Install Nix** with the [Determinate installer](https://determinate.systems/nix-installer/) (this config expects Determinate Nix and leaves Nix itself to it):

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

   Open a new terminal afterwards.

2. **Clone this repo** to `~/.config/nixos`, the path `rebuild` expects (set as `flakeDir` in [`user.nix`](user.nix)). This uses git from Nix, so the Xcode command-line tools aren't needed:

   ```bash
   nix run nixpkgs#git -- clone https://github.com/MaxfieldKassel/nix-config ~/.config/nixos
   ```

3. **Add the machine** if it's new: copy [`hosts/Maxs-MacBook-Air.nix`](hosts/Maxs-MacBook-Air.nix) to `hosts/<hostname>.nix`, set `networking.hostName`, and add a `mkSystem` line under `darwinConfigurations` in [`flake.nix`](flake.nix). On a fresh install, set `system.stateVersion` to nix-darwin's newest value (7 at the time of writing). The MacBook's `5` belongs to that machine only.

4. **Move existing dotfiles out of the way.** home-manager refuses to overwrite files it doesn't own, such as an existing `~/.zshrc` or `~/.gitconfig`.

5. **First switch:**

   ```bash
   sudo nix run github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake ~/.config/nixos#<hostname>
   ```

   Open a new terminal. From now on, `rebuild` applies changes.

6. **Optional:** Maccy is sandboxed, so its settings only apply if the terminal has Full Disk Access (System Settings → Privacy & Security → Full Disk Access → kitty). Without it, `rebuild` prints a warning and skips them.

## Everyday use

| Task | Command |
| --- | --- |
| Apply changes | `rebuild` (`nh darwin switch`: builds, shows what changed, switches) |
| Format Nix files | `nix fmt` |
| Build everything and check formatting | `nix flake check` |
| Update inputs by hand | `nix flake update`, then `rebuild` |

Old generations and unused store paths are cleaned weekly (`nh clean all`, keeping the last 5 generations and anything from the past 14 days).

### CI and updates

- **Check** ([`check.yml`](.github/workflows/check.yml)) runs `nix flake check` on macOS for every push to `main` and every PR. It builds each Mac in the flake and checks formatting.
- **Update flake.lock** ([`update-flake-lock.yml`](.github/workflows/update-flake-lock.yml)) runs every Monday. It updates the inputs, builds everything with them, and opens a PR titled either "Update flake.lock" (build passed: merge, then `rebuild`) or "Update flake.lock (build failing)". It can also be started by hand from the Actions tab.

  It needs **Settings → Actions → General → Workflow permissions → "Allow GitHub Actions to create and approve pull requests"** turned on.

## Layout

| Path | What's in it |
| --- | --- |
| `flake.nix` | Inputs, the `mkSystem` helper, one line per machine, checks, formatter, dev shell |
| `user.nix` | Username, name, email, and where the repo is cloned |
| `hosts/` | One file per machine: hostname, `stateVersion`, hardware-specific bits |
| `modules/shared.nix` | System config for every machine (Docker, …) |
| `modules/theme.nix` | Colour theme and terminal font for every app (Stylix); change `scheme` to switch |
| `modules/darwin.nix` | macOS: apps, system defaults, Dock, Rectangle/Maccy settings, Colima, nh |
| `modules/nixos.nix`, `modules/nixos-desktop.nix` | NixOS base config, and the desktop for machines with a screen |
| `home/` | home-manager: one file per program (`cli.nix`, `zsh.nix`, `neovim.nix`, `git.nix`, `kitty.nix`, `vscode.nix`, `kubernetes.nix`) |

To add a program, create `home/<name>.nix` and add it to the imports in [`home/default.nix`](home/default.nix).
