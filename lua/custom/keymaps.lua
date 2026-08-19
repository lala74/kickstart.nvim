-- NOTE: DLA: C-p not work properly for tmux + docker so should not assign this keymap to any function
-- <Tab> is link with <C-i> so should not assign <Tab> to any function. This to make sure <C-i> can jump forward (opposited to <C-o>)

local map = vim.keymap.set
local opt_default = { noremap = true, silent = false }

-- Toggle highlight
map('n', '<leader>l', ':set hlsearch!<CR>', { noremap = true, silent = true, desc = 'Toggle highlight search' })

-- Map Ctrl-s to save the file in normal and insert mode
map('n', '<C-s>', ':w<CR>', opt_default)
map('i', '<C-s>', '<Esc>:w<CR>', opt_default)

-- Copy to clipboard from anywhere
map('v', '<C-c>', ':OSCYankVisual<CR>', opt_default)

-- Map Ctrl-c to Esc in normal mode
map('n', '<C-c>', '<Esc>', opt_default)

-- Toggle comment
map('n', '<C-\\>', '<plug>NERDCommenterToggle', opt_default)
map('v', '<C-\\>', '<plug>NERDCommenterToggle', opt_default)

-- Toggle tagbar, display class, file structure
map('n', '<F8>', ':TagbarToggle<CR>', opt_default)

-- Go to next/previous tab
--map('n', '<Tab>', ':tabnext<CR>', opt_default)
map('n', '<S-Tab>', ':tabprevious<CR>', opt_default)

-- Map <leader>w to toggle the 'wrap' option
map('n', '<leader>wr', function()
  vim.wo.wrap = not vim.wo.wrap
end, { noremap = true, silent = true, desc = 'Toggle Wrap' })
