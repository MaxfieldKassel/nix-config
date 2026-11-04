{
  config,
  osConfig,
  pkgs,
  user,
  ...
}: let
  # Keymap with a description, so which-key can show what it does.
  mkKey = mode: key: action: desc: {
    inherit mode key action;
    options.desc = desc;
  };
  raw = code: {__raw = code;};

  # This machine's configuration in the repo, so nixd can complete and document its options.
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  flake = ''(builtins.getFlake "${config.home.homeDirectory}/${user.flakeDir}")'';
  machine = "${flake}.${
    if isDarwin
    then "darwinConfigurations"
    else "nixosConfigurations"
  }.\"${osConfig.networking.hostName}\"";
  # Telescope searches hidden files too (e.g. .github/), but never .git/.
  rgHidden = ["--hidden" "--glob=!**/.git/*"];
in {
  programs.nixvim = {
    enable = true;
    nixpkgs.source = pkgs.path;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    withRuby = false;
    withPython3 = false;

    opts = {
      number = true;
      relativenumber = true;
      mouse = "a";
      termguicolors = true;
      showmode = false; # lualine already shows the mode
      cursorline = true;
      sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions";
      exrc = true; # load .nvim.lua from project root

      clipboard = "unnamedplus"; # y/p use the system clipboard
      undofile = true; # keep undo history after closing a file
      ignorecase = true; # case-insensitive search...
      smartcase = true; # ...unless the search has a capital letter
      signcolumn = "yes"; # don't shift text when git/diagnostic signs appear
      scrolloff = 8;
      splitright = true;
      splitbelow = true;
      updatetime = 250;
      # Shown with \tl (toggles `list`)
      listchars = {
        tab = "→ ";
        space = "·";
        trail = "•";
        eol = "¶";
      };
    };

    colorschemes.onedark.enable = true;

    # Show diagnostic messages inline (Neovim 0.11+ only shows signs by default).
    diagnostic.settings = {
      virtual_text = true;
      severity_sort = true;
      float.border = "rounded";
    };

    # LSP (native nvim 0.11+). nixvim installs the server binaries and
    # nvim-lspconfig provides their default configs (cmd, filetypes, root markers).
    # Neovim's built-in LSP keys: K hover, grn rename, gra code action, grr references,
    # gri implementation, [d / ]d next/previous diagnostic. gd is added below.
    lsp.servers = {
      pyright.enable = true;
      ruff.enable = true;
      ts_ls.enable = true;
      # Completion, hover docs and checks for this repo's nix-darwin/NixOS and home-manager options.
      nixd = {
        enable = true;
        config.settings.nixd = {
          nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
          options = {
            # "nixos" replaces nixd's built-in NixOS option set instead of duplicating it.
            ${
              if isDarwin
              then "nix-darwin"
              else "nixos"
            }.expr = "${machine}.options";
            home-manager.expr = "${machine}.options.home-manager.users.type.getSubOptions [ ]";
          };
        };
      };
      lua_ls.enable = true;
      bashls.enable = true;
      terraformls.enable = true;
      jsonls.enable = true;
      # Kubernetes schema (completion + validation) for manifests in the usual places; other
      # YAML (GitHub Actions, compose, ...) keeps its SchemaStore schema. Any file can opt in
      # with a `# yaml-language-server: $schema=...` modeline.
      yamlls = {
        enable = true;
        config.settings.yaml.schemas.kubernetes = [
          "*.k8s.yaml"
          "**/k8s/**/*.{yaml,yml}"
          "**/kubernetes/**/*.{yaml,yml}"
          "**/manifests/**/*.{yaml,yml}"
          "**/deploy/**/*.{yaml,yml}"
        ];
      };
    };

    keymaps = [
      (mkKey "i" "jk" "<Esc>" "Exit insert mode")

      # Find (Telescope)
      (mkKey "n" "<leader>ff" "<cmd>Telescope find_files<CR>" "Files")
      (mkKey "n" "<leader>fg" "<cmd>Telescope live_grep<CR>" "Grep")
      (mkKey "n" "<leader>fb" "<cmd>Telescope buffers<CR>" "Buffers")
      (mkKey "n" "<leader>fh" "<cmd>Telescope help_tags<CR>" "Help")
      (mkKey "n" "<leader>fu" "<cmd>Telescope undo<CR>" "Undo history")
      (mkKey "n" "<leader>fr" "<cmd>Telescope lsp_references<CR>" "References")
      (mkKey "n" "<leader>fs" "<cmd>Telescope lsp_document_symbols<CR>" "Symbols")
      (mkKey "n" "<leader>fd" "<cmd>Telescope diagnostics<CR>" "Diagnostics")
      (mkKey "n" "<leader>fo" "<cmd>Telescope oldfiles<CR>" "Recent files")
      (mkKey "n" "<leader>f/" "<cmd>Telescope current_buffer_fuzzy_find<CR>" "Search in file")

      # Code
      (mkKey "n" "gd" (raw "vim.lsp.buf.definition") "Go to definition")
      (mkKey ["n" "v"] "<leader>cf" (raw ''function() require("conform").format({ async = true, lsp_format = "fallback" }) end'') "Format")

      # Git
      (mkKey "n" "<leader>gg" "<cmd>LazyGit<CR>" "Lazygit")
      (mkKey "n" "<leader>gH" "<cmd>Gitsigns preview_hunk<CR>" "Preview hunk")
      (mkKey "n" "<leader>gB" "<cmd>Gitsigns toggle_current_line_blame<CR>" "Toggle line blame")
      (mkKey "n" "<leader>gD" "<cmd>Gitsigns diffthis<CR>" "Diff file")
      (mkKey "n" "]h" (raw ''function() require("gitsigns").nav_hunk("next") end'') "Next git change")
      (mkKey "n" "[h" (raw ''function() require("gitsigns").nav_hunk("prev") end'') "Previous git change")
      (mkKey "n" "<leader>gs" "<cmd>Gitsigns stage_hunk<CR>" "Stage/unstage change")
      (mkKey "n" "<leader>gr" "<cmd>Gitsigns reset_hunk<CR>" "Undo change")

      # Windows
      (mkKey "n" "<leader>wv" "<cmd>vsplit<CR>" "Split vertically")
      (mkKey "n" "<leader>ws" "<cmd>split<CR>" "Split horizontally")
      (mkKey "n" "<leader>ww" "<cmd>wincmd w<CR>" "Next window")
      (mkKey "n" "<leader>wt" "<cmd>ToggleTerm<CR>" "Terminal")

      # File tree and toggles
      (mkKey "n" "<leader>e" "<cmd>NvimTreeToggle<CR>" "File tree")
      (mkKey "n" "<leader>tl" "<cmd>set list!<CR>" "Show whitespace")

      # Claude Code
      (mkKey "n" "<leader>ac" "<cmd>ClaudeCode<CR>" "Open Claude Code")
      (mkKey "n" "<leader>af" "<cmd>ClaudeCodeFocus<CR>" "Focus Claude")
      (mkKey "n" "<leader>ab" "<cmd>ClaudeCodeAdd %<CR>" "Add file to context")
      (mkKey "v" "<leader>as" "<cmd>ClaudeCodeSend<CR>" "Send selection")
      (mkKey "n" "<leader>aa" "<cmd>ClaudeCodeDiffAccept<CR>" "Accept diff")
      (mkKey "n" "<leader>ad" "<cmd>ClaudeCodeDiffDeny<CR>" "Reject diff")
    ];

    plugins = {
      lspconfig.enable = true;

      # Completion from LSP, file paths, snippets and open buffers.
      # Tab accepts (like VS Code), Ctrl-Space opens the menu, Ctrl-e closes it.
      blink-cmp = {
        enable = true;
        settings = {
          keymap.preset = "super-tab";
          signature.enabled = true;
          completion.documentation.auto_show = true;
        };
      };

      # Formatting on \cf (not on save, since autosave writes on every change).
      conform-nvim = {
        enable = true;
        autoInstall.enable = true;
        settings.formatters_by_ft = {
          nix = ["alejandra"];
          python = ["ruff_organize_imports" "ruff_format"];
          lua = ["stylua"];
          sh = ["shfmt"];
          bash = ["shfmt"];
          javascript = ["prettierd"];
          typescript = ["prettierd"];
          javascriptreact = ["prettierd"];
          typescriptreact = ["prettierd"];
          json = ["prettierd"];
          yaml = ["prettierd"];
          css = ["prettierd"];
          html = ["prettierd"];
          "*" = ["trim_whitespace"];
        };
      };

      nvim-tree = {
        enable = true;
        settings = {
          view = {
            width = 30;
            side = "left";
          };
          filters.dotfiles = false;
          # Highlight the file you're editing in the tree, opening its folders as you switch.
          update_focused_file.enable = true;
          # Mark files with LSP errors/warnings in the tree.
          diagnostics.enable = true;
        };
      };

      telescope = {
        enable = true;
        settings = {
          defaults.vimgrep_arguments =
            ["rg" "--color=never" "--no-heading" "--with-filename" "--line-number" "--column" "--smart-case"]
            ++ rgHidden;
          pickers.find_files.find_command = ["rg" "--files" "--color=never"] ++ rgHidden;
        };
        extensions = {
          fzf-native.enable = true;
          undo.enable = true;
        };
      };

      treesitter = {
        enable = true;
        highlight.enable = true;
        indent.enable = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          nix
          lua
          luadoc
          vim
          vimdoc
          python
          javascript
          typescript
          tsx
          bash
          json
          yaml
          toml
          markdown
          markdown_inline
          html
          css
          dockerfile
          hcl
          terraform
          regex
          diff
          gitcommit
        ];
      };

      lualine.enable = true;
      gitsigns.enable = true;
      indent-blankline.enable = true;
      nvim-autopairs.enable = true;
      web-devicons.enable = true;
      vim-surround.enable = true;
      lazygit.enable = true;

      # Group names for the \ menus; each keymap above carries its own description.
      which-key = {
        enable = true;
        settings.spec = [
          {
            __unkeyed-1 = "<leader>f";
            group = "Find";
          }
          {
            __unkeyed-1 = "<leader>c";
            group = "Code";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
          }
          {
            __unkeyed-1 = "<leader>w";
            group = "Windows";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "Toggle";
          }
          {
            __unkeyed-1 = "<leader>a";
            group = "AI / Claude";
          }
        ];
      };

      toggleterm = {
        enable = true;
        settings = {
          open_mapping = "[[<C-\\>]]";
          direction = "float";
          float_opts.border = "curved";
        };
      };

      auto-session = {
        enable = true;
        settings = {
          log_level = "error";
          suppressed_dirs = ["~/"];
        };
      };
    };

    # Spell check where you write prose (z= suggests fixes, zg adds a word).
    autoCmd = [
      {
        event = "FileType";
        pattern = ["gitcommit" "markdown"];
        command = "setlocal spell";
      }
    ];

    extraPlugins = with pkgs.vimPlugins; [
      vim-be-good
      claudecode-nvim
      autosave-nvim
    ];

    extraConfigLua = ''
      -- autosave-nvim is nullishamy/autosave.nvim. Each top-level option replaces its default
      -- entirely, so the filters list keeps the three the plugin needs to work.
      local autosave_filters = require("autosave.filters")
      require("autosave").setup {
        events = {
          register = true,
          triggers = { "InsertLeave", "TextChanged" },
        },
        filters = {
          autosave_filters.writeable,
          autosave_filters.not_empty,
          autosave_filters.modified,
          autosave_filters.modifiable,
          autosave_filters.filetype("gitcommit"),
          autosave_filters.filetype("markdown"),
        },
        hooks = {
          post_write = function()
            vim.api.nvim_echo({ { "Autosaved at " .. os.date("%H:%M:%S") } }, false, {})
          end,
        },
      }

      require("claudecode").setup()

      -- Close nvim-tree when it's the last non-floating window (on user quit)
      vim.api.nvim_create_autocmd('QuitPre', {
        callback = function()
          local wins = vim.api.nvim_list_wins()
          local tree_wins = {}
          local floating_wins = {}
          for _, w in ipairs(wins) do
            if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == 'NvimTree' then
              table.insert(tree_wins, w)
            end
            if vim.api.nvim_win_get_config(w).relative ~= "" then
              table.insert(floating_wins, w)
            end
          end
          if #wins - #floating_wins - #tree_wins == 1 then
            for _, w in ipairs(tree_wins) do
              vim.api.nvim_win_close(w, true)
            end
          end
        end,
      })

      -- Open the file tree on startup, but not when Neovim is opened for a git commit
      -- message or another editor-style task (\e toggles it any time).
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          local ft = vim.bo.filetype
          if ft == 'gitcommit' or ft == 'gitrebase' or ft == 'diff' then
            return
          end
          pcall(vim.cmd, 'NvimTreeOpen')
          pcall(vim.cmd, 'wincmd p')
        end,
      })
    '';
  };
}
