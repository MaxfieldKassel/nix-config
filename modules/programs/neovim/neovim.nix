{ pkgs }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    extraConfig = ''
      set number
      set relativenumber
      set mouse=a
      set termguicolors
      colorscheme gruvbox
      set listchars=tab:→\ ,space:·,trail:•,eol:¶
      set showmode
      set cursorline

      " Keybindings
      nnoremap <leader>ff :Telescope find_files<CR>
      nnoremap <leader>fg :Telescope live_grep<CR>
      nnoremap <leader>fb :Telescope buffers<CR>
      nnoremap <leader>fh :Telescope help_tags<CR>
      inoremap jk <Esc>

      " LSP Configurations
      lua << EOF
      local lspconfig = require('lspconfig')
      lspconfig.pyright.setup{}
      lspconfig.ts_ls.setup{}
      EOF

      " File Manager (nvim-tree)
      lua << EOF
      require('nvim-tree').setup {
        view = {
          width = 30,
          side = 'left'
        },
        filters = {
          dotfiles = false,
        },
      }
      EOF

      " Utility functions
      function! TrimTrailingWhitespace()
        let l:save = winsaveview()
        %s/\s\+$//e
        call winrestview(l:save)
      endfunction
      command! TrimWhitespace :call TrimTrailingWhitespace()
    '';

    plugins = [
      # Add your plugins here based on your setup
      pkgs.vimPlugins.nvim-tree-lua # File explorer
      pkgs.vimPlugins.telescope-nvim # Fuzzy finder
      pkgs.vimPlugins.nvim-lspconfig # LSP configuration
      pkgs.vimPlugins.lualine-nvim # Statusline
      pkgs.vimPlugins.nvim-treesitter # Syntax highlighting
      pkgs.vimPlugins.nvim-colorizer-lua # Color highlighter
      pkgs.vimPlugins.comment-nvim # Comment toggling
      pkgs.vimPlugins.gitsigns-nvim # Git integration
      pkgs.vimPlugins.indent-blankline-nvim # Indent guides
      pkgs.vimPlugins.nvim-autopairs # Autopairs for brackets
      pkgs.vimPlugins.which-key-nvim # Keybinding helper
      pkgs.vimPlugins.vim-surround # Surrounding text manipulation
      pkgs.vimPlugins.gruvbox
    ];

    # Optional: Default editor
    defaultEditor = true;
  };
}
