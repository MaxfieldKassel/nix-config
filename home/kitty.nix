{
  config,
  user,
  ...
}: {
  programs.kitty = {
    enable = true;
    # Font, colours and background opacity come from Stylix (modules/theme.nix).

    settings = {
      window_padding_width = 5;
      undercurl_style = "thick-dense";

      # splits: ctrl+shift+e / ctrl+shift+s split side-by-side / top-and-bottom.
      # stack: ctrl+option+z zooms the current split to the whole tab and back.
      enabled_layouts = "splits,stack";

      tab_separator = " |";
      tab_bar_min_tabs = 2;
      tab_bar_edge = "top";
      tab_bar_style = "separator";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";

      scrollback_lines = 10000;

      detect_urls = true;
      # No keybinding needs this; "yes" would let any program in the terminal (even over SSH) control kitty.
      allow_remote_control = "no";

      confirm_os_window_close = 0; # Don't confirm when closing a window
    };

    extraConfig = ''
      modify_font underline_position 0
      modify_font underline_thickness 100%
    '';

    keybindings = {
      # New tabs, windows and splits all open in the current folder.
      "ctrl+shift+t" = "new_tab_with_cwd";
      "super+t" = "new_tab_with_cwd";
      "super+shift+t" = "new_tab_with_cwd";
      "kitty_mod+enter" = "new_window_with_cwd";
      "super+enter" = "new_window_with_cwd";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "cmd+r" = "set_tab_title";

      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
      "cmd+6" = "goto_tab 6";
      "cmd+7" = "goto_tab 7";
      "cmd+8" = "goto_tab 8";
      "cmd+9" = "goto_tab 9";
      "cmd+0" = "goto_tab 0";

      "ctrl+shift+e" = "launch --location=vsplit --cwd=current"; # side by side
      "ctrl+shift+s" = "launch --location=hsplit --cwd=current"; # top and bottom
      # Move between splits with kitty's defaults: ctrl+shift+] / ctrl+shift+[.
      # (ctrl+option+arrows belong to Rectangle.)
      "ctrl+alt+z" = "toggle_layout stack"; # zoom the current split
      "ctrl+shift+f" = "toggle_fullscreen";

      # kitty.conf is generated (read-only), so open the file it comes from.
      "kitty_mod+," = "launch --type=tab --cwd=${config.home.homeDirectory}/${user.flakeDir} nvim home/kitty.nix";
    };
  };
}
