# One colour theme and terminal font for every app, via Stylix: kitty, the prompt, bat, btop, fzf,
# lazygit, k9s, kubecolor, gdu and VS Code. To switch themes, change `scheme` to another file
# name from https://tinted-theming.github.io/tinted-gallery/ and rebuild.
{pkgs, ...}: let
  scheme = "onedark";
in {
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${scheme}.yaml";
    polarity = "dark";

    # Nerd fonts include the icons used by eza, the prompt, Neovim, ...
    # https://www.nerdfonts.com/font-downloads
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack Nerd Font";
      };
      sizes.terminal = 14;
    };
    opacity.terminal = 0.9;
  };

  home-manager.sharedModules = [
    {
      stylix.targets = {
        # Neovim keeps onedark.nvim (home/neovim.nix), a hand-tuned One Dark with richer
        # highlighting than Stylix's generated one. Enable this if you change `scheme`.
        nixvim.enable = false;
        # Only colours for VS Code; its font sizes stay as they are.
        vscode.fonts.enable = false;
        # Not used here, and Stylix's rofi theme sets an option this home-manager has renamed,
        # which prints a warning on every rebuild.
        rofi.enable = false;
      };
    }
  ];
}
