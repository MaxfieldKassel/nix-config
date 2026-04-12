{pkgs, ...}: {
  programs.nixvim = {
    enable = true;
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
      showmode = true;
      cursorline = true;
      sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions";
      exrc = true; # load .nvim.lua from project root
    };

    colorschemes.onedark.enable = true;

    keymaps = [
      {
        mode = "i";
        key = "jk";
        action = "<Esc>";
      }

      # Telescope
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<CR>";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<CR>";
      }

      # Git
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>LazyGit<CR>";
      }
      {
        mode = "n";
        key = "<leader>gH";
        action = "<cmd>Gitsigns preview_hunk<CR>";
      }
      {
        mode = "n";
        key = "<leader>gB";
        action = "<cmd>Gitsigns toggle_current_line_blame<CR>";
      }
      {
        mode = "n";
        key = "<leader>gD";
        action = "<cmd>Gitsigns diffthis<CR>";
      }

      # Windows
      {
        mode = "n";
        key = "<leader>wv";
        action = "<cmd>vsplit<CR>";
      }
      {
        mode = "n";
        key = "<leader>ws";
        action = "<cmd>split<CR>";
      }
      {
        mode = "n";
        key = "<leader>ww";
        action = "<cmd>wincmd w<CR>";
      }
      {
        mode = "n";
        key = "<leader>wt";
        action = "<cmd>ToggleTerm<CR>";
      }

      # Claude Code
      {
        mode = "n";
        key = "<leader>ac";
        action = "<cmd>ClaudeCode<CR>";
      }
      {
        mode = "v";
        key = "<leader>as";
        action = "<cmd>ClaudeCodeSend<CR>";
      }
    ];

    plugins = {
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
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          nix
          lua
          python
          javascript
          typescript
          bash
          json
          yaml
          markdown
          html
          css
        ];
      };

      lualine.enable = true;
      comment.enable = true;
      gitsigns.enable = true;
      indent-blankline.enable = true;
      nvim-autopairs.enable = true;
      web-devicons.enable = true;
      vim-surround.enable = true;
      lazygit.enable = true;

      which-key = {
        enable = true;
        settings.spec = [
          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
          }
          {
            __unkeyed-1 = "<leader>gg";
            desc = "Open Lazygit";
          }
          {
            __unkeyed-1 = "<leader>a";
            group = "AI / Claude";
          }
          {
            __unkeyed-1 = "<leader>ac";
            desc = "Open Claude Code";
          }
          {
            __unkeyed-1 = "<leader>as";
            desc = "Send selection";
            mode = "v";
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
          auto_session_suppress_dirs = ["~/"];
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-be-good
      claudecode-nvim
      autosave-nvim
    ];

    extraConfigLua = ''
      vim.opt.listchars = { tab = '→ ', space = '·', trail = '•', eol = '¶' }

      -- LSP (native nvim 0.11+)
      vim.lsp.config('pyright', {})
      vim.lsp.config('ts_ls', {})
      vim.lsp.enable({'pyright', 'ts_ls'})

      require("autosave").setup {
        enabled = true,
        execution_message = "Autosaved at " .. os.date("%H:%M:%S"),
        events = {"InsertLeave", "TextChanged"},
        conditions = {
          exists = true,
          filetype_is_not = {"gitcommit", "markdown"},
          modifiable = true,
        },
        write_all_buffers = false,
      }

      require("claudecode").setup()

      vim.api.nvim_create_user_command('TrimWhitespace', function()
        local view = vim.fn.winsaveview()
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.winrestview(view)
      end, {})

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

      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          pcall(vim.cmd, 'NvimTreeOpen')
          pcall(vim.cmd, 'wincmd p')
        end,
      })
    '';
  };
}
