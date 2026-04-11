{pkgs}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    withRuby = false;
    withPython3 = false;

    plugins = with pkgs.vimPlugins; [
      # Core
      nvim-tree-lua
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-undo-nvim
      lualine-nvim
      nvim-treesitter
      nvim-colorizer-lua
      comment-nvim
      gitsigns-nvim
      indent-blankline-nvim
      nvim-autopairs
      which-key-nvim
      vim-surround
      vim-be-good
      onedark-nvim

      # UI
      cinnamon-nvim
      hop-nvim
      twilight-nvim
      nvim-web-devicons
      mini-nvim

      # Git
      diffview-nvim
      vim-fugitive
      git-messenger-vim

      # Terminal & Sessions
      toggleterm-nvim
      auto-session
      autosave-nvim

      # Copilot
      copilot-vim
    ];

    initLua = ''
      -- Editor options
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.mouse = 'a'
      vim.opt.termguicolors = true
      vim.opt.listchars = { tab = '→ ', space = '·', trail = '•', eol = '¶' }
      vim.opt.showmode = true
      vim.opt.cursorline = true

      -- Keymaps
      local map = vim.keymap.set

      map('i', 'jk', '<Esc>')

      map('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
      map('n', '<leader>fg', '<cmd>Telescope live_grep<CR>')
      map('n', '<leader>fb', '<cmd>Telescope buffers<CR>')
      map('n', '<leader>fh', '<cmd>Telescope help_tags<CR>')

      map('n', '<leader>gc', '<cmd>Git commit<CR>')
      map('n', '<leader>gs', '<cmd>Git status<CR>')
      map('n', '<leader>gd', '<cmd>Git diff<CR>')
      map('n', '<leader>gt', '<cmd>Git blame<CR>')
      map('n', '<leader>gl', '<cmd>Git log<CR>')
      map('n', '<leader>gR', '<cmd>Git rebase<CR>')
      map('n', '<leader>gS', '<cmd>Git stash<CR>')
      map('n', '<leader>gP', '<cmd>Git push<CR>')
      map('n', '<leader>gC', '<cmd>Git checkout<CR>')
      map('n', '<leader>gA', '<cmd>Git add .<CR>')
      map('n', '<leader>gH', '<cmd>Gitsigns preview_hunk<CR>')
      map('n', '<leader>gB', '<cmd>Gitsigns toggle_current_line_blame<CR>')
      map('n', '<leader>gD', '<cmd>Gitsigns diffthis<CR>')

      map('n', '<leader>tn', '<cmd>tabnew<CR>')
      map('n', '<leader>to', '<cmd>tabonly<CR>')
      map('n', '<leader>tc', '<cmd>tabclose<CR>')
      map('n', '<leader>tl', '<cmd>tabnext<CR>')
      map('n', '<leader>th', '<cmd>tabprevious<CR>')

      map('n', '<leader>wv', '<cmd>vsplit<CR>')
      map('n', '<leader>ws', '<cmd>split<CR>')
      map('n', '<leader>ww', '<cmd>wincmd w<CR>')
      map('n', '<leader>wt', '<cmd>ToggleTerm<CR>')

      -- Trim trailing whitespace command
      vim.api.nvim_create_user_command('TrimWhitespace', function()
        local view = vim.fn.winsaveview()
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.winrestview(view)
      end, {})

      -- Auto-open file explorer
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function() vim.cmd('NvimTreeOpen') end,
      })

      -- Autosave
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

      -- LSP (native nvim 0.11+)
      vim.lsp.config('pyright', {})
      vim.lsp.config('ts_ls', {})
      vim.lsp.enable({'pyright', 'ts_ls'})

      -- File explorer
      require('nvim-tree').setup {
        view = { width = 30, side = 'left' },
        filters = { dotfiles = false },
      }

      -- Pairs, comments, colorizer
      require('nvim-autopairs').setup()
      require('Comment').setup()
      require('colorizer').setup()

      -- UI
      require('cinnamon').setup()
      require('hop').setup()
      require('twilight').setup()
      require('mini.indentscope').setup()
      require('gitsigns').setup()

      -- Statusline
      require('lualine').setup {
        options = { theme = 'auto' },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'},
        },
      }

      -- Telescope
      require('telescope').load_extension('fzf')

      -- Floating terminal
      require("toggleterm").setup {
        open_mapping = [[<C-\>]],
        direction = 'float',
        float_opts = { border = 'curved' },
      }

      -- Session management
      vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
      require("auto-session").setup {
        log_level = "info",
        auto_session_suppress_dirs = { "~/" },
        auto_session_create_enabled = true,
        auto_save_enabled = true,
        auto_restore_enabled = true,
      }
    '';
  };
}
