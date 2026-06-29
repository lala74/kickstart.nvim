-- Use system gopls (not mason-managed). Install via: go install golang.org/x/tools/gopls@latest
vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
})
vim.lsp.enable 'gopls'

-- NOTE: rmagatti/auto-session
-- Recommended by README
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
