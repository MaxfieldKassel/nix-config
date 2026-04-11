-- Project-local config for ~/.config/nixos
-- Loaded automatically via exrc when opening Neovim in this directory.

local Terminal = require('toggleterm.terminal').Terminal

local function rebuild()
  Terminal:new({
    cmd = 'darwin-rebuild switch --flake . 2>&1',
    direction = 'float',
    float_opts = { border = 'curved' },
    close_on_exit = false,
  }):toggle()
end

vim.keymap.set('n', '<leader>rb', rebuild, { desc = 'Rebuild Darwin config' })
