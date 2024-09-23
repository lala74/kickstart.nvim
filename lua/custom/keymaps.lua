vim.keymap.set('n', '<leader>l', ':set hlsearch!<CR>', { noremap = true, silent = true, desc = 'Toggle highlight search' })

-- Map Ctrl-s to save the file in normal and insert mode
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>', { noremap = true, silent = true })

vim.keymap.set('v', '<C-c>', ':OSCYankVisual<CR>', { noremap = true, silent = true })

-- Map Ctrl-c to Esc in normal mode
vim.keymap.set('n', '<C-c>', '<Esc>', { noremap = true, silent = true })

-- Toggle comment
vim.keymap.set('n', '<C-\\>', '<plug>NERDCommenterToggle', { noremap = true, silent = true })
vim.keymap.set('v', '<C-\\>', '<plug>NERDCommenterToggle', { noremap = true, silent = true })

-- Map <leader>w to toggle the 'wrap' option
vim.keymap.set('n', '<leader>wr', function()
  vim.wo.wrap = not vim.wo.wrap
end, { noremap = true, silent = true, desc = 'Toggle Wrap' })

-- Searching with telescope
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<C-f>', builtin.live_grep, { desc = '[S]earch by [G]rep' })
-- C-p is used for go to next in telescope
--vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = '[S]earch [F]iles' })
