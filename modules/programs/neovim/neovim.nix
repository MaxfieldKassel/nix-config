{pkgs}: {
  programs.nixvim = {
    enable = true;

    # Make Neovim the default editor
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # ======================================================
    # 1. UI & Core Options
    # ======================================================
    opts = {
      number = true;
      relativenumber = true;
      mouse = "a";
      termguicolors = true;
      listchars = "tab:→ ,space:·,trail:•,eol:¶";
      showmode = true;
      cursorline = true;
      sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions";
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options = {
          desc = "Find files";
        };
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
        options = {
          desc = "Live grep";
        };
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<CR>";
        options = {
          desc = "Find buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<CR>";
        options = {
          desc = "Find help";
        };
      }
      {
        mode = "i";
        key = "jk";
        action = "<Esc>";
        options = {
          desc = "Exit insert mode";
        };
      }
    ];

    # ======================================================
    # 2. Plugins
    # ======================================================
    plugins = {
      # Explicitly enable web-devicons to remove the warning
      web-devicons = {
        enable = true;
      };

      # Statusline
      lualine = {
        enable = true;
        settings = {
          options = {
            theme = "auto";
          };
          sections = {
            lualine_a = ["mode"];
            lualine_b = [
              "branch"
              "diff"
              "diagnostics"
            ];
            lualine_c = ["filename"];
            lualine_x = [
              "encoding"
              "fileformat"
              "filetype"
            ];
            lualine_y = ["progress"];
            lualine_z = ["location"];
          };
        };
      };

      # Treesitter
      treesitter.enable = true;

      # File Explorer
      nvim-tree = {
        enable = true;
        settings = {
          view = {
            width = 30;
            side = "left";
          };
          filters = {
            dotfiles = false;
          };
        };
      };

      # Telescope
      telescope = {
        enable = true;
        extensions = {
          "fzf-native".enable = true;
          undo.enable = true;
        };
      };

      # LSP
      lsp = {
        enable = true;
        servers = {
          pyright = {
            enable = true;
          };
          ts_ls = {
            enable = true;
          };
          # rust_analyzer = {
          #   enable = true;
          # };
          nixd = {
            enable = true;
          };
          terraform_lsp = {
            enable = true;
          };
        };
      };

      # Git
      gitsigns.enable = true;
      fugitive.enable = true;
      diffview.enable = true;

      # Terminal
      toggleterm = {
        enable = true;
        settings = {
          direction = "float";
          float_opts = {
            border = "curved";
          };
        };
      };

      # Autosave
      "auto-save" = {
        enable = true;
        settings = {
          write_all_buffers = false;
          debounce_delay = 1000;
        };
      };

      # Keyboard discipline
      hardtime = {
        enable = false;
      };

      # Commenting, pairs, etc.
      comment = {
        enable = true;
      };
      vim-surround = {
        enable = true;
      };
      which-key = {
        enable = true;
      };

      # UI niceties
      hop = {
        enable = true;
      };
      twilight = {
        enable = true;
      };
      mini = {
        enable = true;
        modules = {
          indentscope = {
            enable = true;
          };
        };
      };

      # Auto-session
      "auto-session" = {
        enable = true;
        settings = {
          log_level = "info";
          auto_save_enabled = true;
          auto_restore_enabled = true;
          auto_session_create_enabled = true;
          auto_session_suppress_dirs = ["~/"];
        };
      };
    };

    # ======================================================
    # 3. Autocommands
    # ======================================================
    autoCmd = [
      {
        event = "VimEnter";
        command = "NvimTreeOpen";
      }
    ];
  };
}
