{ pkgs }:
{
  programs.neovim = {
    # Enable Neovim, aliases, and optionally set it as the default editor
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    #
    # 1. Plugins
    #
    plugins = with pkgs.vimPlugins; [
      ################################################################
      # Base / Default Plugins
      ################################################################
      nvim-tree-lua # File explorer
      telescope-nvim # Fuzzy finder
      nvim-lspconfig # LSP configuration
      lualine-nvim # Statusline
      nvim-treesitter # Syntax highlighting
      nvim-colorizer-lua # Color highlighter
      comment-nvim # Comment toggling (gc to comment lines)
      gitsigns-nvim # Git integration (signs in the gutter)
      indent-blankline-nvim # Indentation guides
      nvim-autopairs # Auto-close pairs
      which-key-nvim # Keybinding helper
      vim-surround # Surround text manipulation
      vim-be-good # Fun practice plugin
      onedark-nvim # OneDark colorscheme (check if it provides "onedark" for lualine)
      nvim-fzf # Fuzzy finder for files 

      ################################################################
      # UI Enhancements
      ################################################################
      cinnamon-nvim # Smooth scrolling
      hop-nvim # Faster cursor motions
      twilight-nvim # Dim out inactive code
      mini-indentscope # Enhanced indent scope visualization
      nvim-web-devicons # Icons for statusline, file explorer, etc.
      mini-nvim # For mini.plugins like mini.icons, etc.

      ################################################################
      # Git Enhancements
      ################################################################
      diffview-nvim # Modern Git diff interface
      vim-fugitive # Essential Git commands in Neovim
      git-messenger-vim # Show commit messages in a floating window
      gitsigns-nvim # Git signs in the gutter

      ################################################################
      # Terminal & Sessions
      ################################################################
      toggleterm-nvim # Floating terminal
      auto-session # Auto-save & restore sessions

      ################################################################
      # Telescope Extras
      ################################################################
      telescope-fzf-native-nvim # Faster fuzzy search for Telescope

      ################################################################
      # Github Copilot
      ################################################################
      copilot-vim # Github Copilot
    ];

    #
    # 2. Neovim Configuration
    #
    extraConfig = ''
      "=================================================="
      "== BASIC EDITOR SETTINGS                        =="
      "=================================================="
      set number
      set relativenumber
      set mouse=a
      set termguicolors
      set listchars=tab:→\ ,space:·,trail:•,eol:¶
      set showmode
      set cursorline

      " Basic keybindings
      nnoremap <leader>ff :Telescope find_files<CR>
      nnoremap <leader>fg :Telescope live_grep<CR>
      nnoremap <leader>fb :Telescope buffers<CR>
      nnoremap <leader>fh :Telescope help_tags<CR>
      

      " Git keybindings
      nnoremap <leader>gc :Git commit<CR>
      nnoremap <leader>gs :Git status<CR>
      nnoremap <leader>gd :Git diff<CR>
      nnoremap <leader>gt :Git blame<CR>
      nnoremap <leader>gl :Git log<CR>
      nnoremap <leader>gR :Git rebase<CR>
      nnoremap <leader>gS :Git stash<CR>
      nnoremap <leader>gP :Git push<CR>


      inoremap jk <Esc>

      " Function to trim trailing whitespace
      function! TrimTrailingWhitespace()
        let l:save = winsaveview()
        %s/\\s\\+$//e
        call winrestview(l:save)
      endfunction
      command! TrimWhitespace :call TrimTrailingWhitespace()

      "=================================================="
      "== LSP CONFIG                                   =="
      "=================================================="
      lua << EOF
        local lspconfig = require('lspconfig')
        -- Example LSP servers:
        lspconfig.pyright.setup({})
        lspconfig.ts_ls.setup({})
      EOF

      "=================================================="
      "== NVIM-TREE CONFIG                             =="
      "=================================================="
      lua << EOF
        require('nvim-tree').setup {
          view = {
            width = 30,
            side = 'left',
          },
          filters = {
            dotfiles = false,
          },
        }
      EOF

      " Auto-open nvim-tree (like VSCode explorer) at startup
      augroup open_nvim_tree
        autocmd!
        autocmd VimEnter * NvimTreeOpen
      augroup END

      "=================================================="
      "== UI ENHANCEMENTS                              =="
      "=================================================="
      lua << EOF
        -- Smooth scrolling
        require('cinnamon').setup()

        -- Hop for faster motions
        require('hop').setup()

        -- Twilight (dims inactive code)
        require('twilight').setup()

        -- mini.indentscope for indent guides
        require('mini.indentscope').setup()

        -- Git signs in the gutter
        require('gitsigns').setup()
      EOF

      "=================================================="
      "== LUALINE (STATUSLINE)                         =="
      "=================================================="
      lua << EOF
        require('lualine').setup {
          options = {
            -- If your installed OneDark plugin truly provides a "onedark" theme:
            -- theme = 'onedark',

            -- Otherwise, fallback to "auto" to avoid warnings
            theme = 'auto',
          },
          sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch', 'diff', 'diagnostics'},
            lualine_c = {'filename'},
            lualine_x = {'encoding', 'fileformat', 'filetype'},
            lualine_y = {'progress'},
            lualine_z = {'location'},
          },
        }
      EOF

      "=================================================="
      "== TELESCOPE FZF (FASTER SEARCH)                =="
      "=================================================="
      lua << EOF
        require('telescope').load_extension('fzf')


      EOF

      "=================================================="
      "== TOGGLETERM (FLOATING TERMINAL)               =="
      "=================================================="
      lua << EOF
        require("toggleterm").setup{
          open_mapping = [[<C-\\>]],
          direction = 'float',
          float_opts = {
            border = 'curved',
          },
        }
      EOF


      "=================================================="
      "== AUTO-SESSION (SESSION MANAGEMENT)            =="
      "=================================================="
      lua << EOF
        -- Add localoptions to fix auto-session warnings
        vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

        require("auto-session").setup {
          log_level = "info",
          auto_session_suppress_dirs = { "~/" },
          auto_session_create_enabled = true,
          auto_save_enabled = true,
          auto_restore_enabled = true,
        }
      EOF
    '';
  };
}
