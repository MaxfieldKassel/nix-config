{pkgs, ...}: let
  # Keymap with a description, so which-key can show what it does.
  mkKey = mode: key: action: desc: {
    inherit mode key action;
    options.desc = desc;
  };
  raw = code: {__raw = code;};
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
      nixd.enable = true;
      lua_ls.enable = true;
      bashls.enable = true;
      terraformls.enable = true;
      jsonls.enable = true;
      yamlls.enable = true;
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

      # Code
      (mkKey "n" "gd" (raw "vim.lsp.buf.definition") "Go to definition")
      (mkKey ["n" "v"] "<leader>cf" (raw ''function() require("conform").format({ async = true, lsp_format = "fallback" }) end'') "Format")

      # Git
      (mkKey "n" "<leader>gg" "<cmd>LazyGit<CR>" "Lazygit")
      (mkKey "n" "<leader>gH" "<cmd>Gitsigns preview_hunk<CR>" "Preview hunk")
      (mkKey "n" "<leader>gB" "<cmd>Gitsigns toggle_current_line_blame<CR>" "Toggle line blame")
      (mkKey "n" "<leader>gD" "<cmd>Gitsigns diffthis<CR>" "Diff file")

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
        };
      };

      telescope = {
        enable = true;
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
