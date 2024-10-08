-- NOTE: lspconfig
-- Not install gopls but use system gopls, manage by go install 'golang.org/x/tools/gopls@<version>' command
require('lspconfig')['gopls'].setup {}

-- NOTE: rmagatti/auto-session
-- Recommended by README
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
