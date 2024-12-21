{ pkgs }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "Hack Nerd Font";
      package = pkgs.nerd-fonts.hack;
      size = 14.0;
    };

    settings = {
      font_features = "Hack Nerd Font +liga +calt";
      background_opacity = 0.9;
      window_padding_width = 5;
      undercurl_style = "thick-dense";

      background = "#131313";
      foreground = "#d6dae4";
      cursor = "#b9b9b9";
      selection_background = "#ffaf00";
      selection_foreground = "#131313";

      color0 = "#1f1f1f";
      color1 = "#f71118";
      color2 = "#2cc55d";
      color3 = "#ecb90f";
      color4 = "#2a84d2";
      color5 = "#4e59b7";
      color6 = "#0f80d5";
      color7 = "#d6dae4";
      color8 = "#d6dae4";
      color9 = "#de342e";
      color10 = "#1dd260";
      color11 = "#f2bd09";
      color12 = "#0f80d5";
      color13 = "#524fb9";
      color14 = "#0f7cda";
      color15 = "#ffffff";

      tab_separator = " |";
      tab_bar_min_tabs = 2;
      tab_bar_edge = "top";
      tab_bar_style = "separator";
      tab_bar_separator_style = "line";
      tab_bar_background = "#282a36";

      active_tab_foreground = "#FFFFFF";
      active_tab_background = "#41C4FF";
      active_tab_font_style = "bold";

      inactive_tab_foreground = "#FFFFFF";
      inactive_tab_background = "#83769C";
      inactive_tab_font_style = "normal";

      scrollback_lines = 10000;

      detect_urls = true;
      allow_remote_control = true;
      shell_integration = true;
    };

    extraConfig = ''
      modify_font underline_position 0
      modify_font underline_thickness 100%

      clipboard_control c
      clipboard_control v
    '';

    keybindings = {
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "cmd+r" = "set_tab_title";
      "ctrl+r" = "set_tab_color";

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

      "ctrl+shift+e" = "new_window";
      "ctrl+shift+s" = "new_window";
      "ctrl+shift+f" = "full_screen";

      "super+shift+t" = "launch --type=tab --cwd=current";
      "super+t" = "launch --type=tab --cwd=current";

      "kitty_mod+." = ''echo "TEST"'';
      "kitty_mod+," = "launch --type=window nvim ~/.config/kitty/kitty.conf";
    };
  };
}
