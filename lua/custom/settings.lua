-- Use system gopls (not mason-managed). Install via: go install golang.org/x/tools/gopls@latest
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if ok then
  capabilities = vim.tbl_deep_extend('force', capabilities, cmp_lsp.default_capabilities())
end

vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  capabilities = capabilities,
  init_options = {
    semanticTokens = true,
  },
  settings = {
    gopls = {
      semanticTokens = true,
    },
  },
})
vim.lsp.enable 'gopls'

-- NOTE: rmagatti/auto-session
-- Recommended by README
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
