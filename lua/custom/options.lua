vim.opt.relativenumber = true

-- Searching with case sensitive or in-sensitive
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Wrap
vim.opt.wrap = true
vim.opt.linebreak = true -- wrap will enter the whole word instead of breaking text

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
