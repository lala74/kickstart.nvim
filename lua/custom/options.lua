vim.opt.relativenumber = true

-- Searching with case sensitive or in-sensitive
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Wrap
vim.opt.wrap = true
vim.opt.linebreak = true -- wrap will enter the whole word instead of breaking text

-- Show file name in the top of nvim
vim.opt.showtabline = 2

-- Tab and shift and >>
vim.opt.tabstop = 4 -- Number of visual spaces that a tab character represents.
-- For example, if you press 'Tab', it will display as 4 spaces in the file.
vim.opt.shiftwidth = 4 -- Number of spaces to use for each indentation level.
-- This controls how many spaces are inserted when you indent a line
-- with commands like '>>' or '<<' or when auto-indentation is applied.
vim.opt.smarttab = true -- Makes 'Tab' key behavior context-aware:
-- - At the beginning of a line, 'Tab' inserts 'shiftwidth' number of spaces.
-- - In other parts of the line, it inserts 'tabstop' number of spaces.
-- Helps maintain consistent indentation.
vim.opt.expandtab = true -- Converts tabs into spaces. When you press 'Tab', it inserts spaces
-- instead of an actual tab character (useful for ensuring consistent
-- formatting across different editors).
vim.opt.smartindent = true -- Enables intelligent auto-indentation for code blocks.
-- Vim will automatically indent based on syntax (like after '{' in C-style languages).
-- This is helpful when writing code, as it reduces the need to manually adjust indentation.
vim.opt.autoindent = true -- Maintains the same level of indentation as the previous line.
-- If you press 'Enter', the new line will be automatically indented
-- at the same level as the line above.
-- This works well with 'smartindent' for code editing.

--vim.cmd [[
--"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
--"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
--"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
--if (empty($TMUX) && getenv('TERM_PROGRAM') != 'Apple_Terminal')
--if (has("nvim"))
--"For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
--let $NVIM_TUI_ENABLE_TRUE_COLOR=1
--endif
--"For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
--"Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
--" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
--if (has("termguicolors"))
--set termguicolors
--endif
--endif
--]]
