-- Use system gopls (not mason-managed). Install via: go install golang.org/x/tools/gopls@latest
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if ok then
  capabilities = vim.tbl_deep_extend('force', capabilities, cmp_lsp.default_capabilities())
end

vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  -- `gopls` resolves to a goenv shim, and goenv picks its Go version from the
  -- nearest go.mod's `go` directive. Inside a vendored dep whose go.mod says
  -- `go 1.23` that downgrades the toolchain, which then fails the workspace's
  -- go.work: "go.work requires go >= 1.26.2 (running go 1.23.2)". Pinning
  -- GOENV_VERSION overrides that per-directory lookup (and it beats a PATH
  -- prepend, which the shim clobbers on its way to `goenv exec`). GOROOT comes
  -- from `goenv init`, so this tracks whatever the goenv global version is.
  cmd_env = vim.env.GOROOT and {
    GOENV_VERSION = vim.fs.basename(vim.env.GOROOT),
  } or nil,
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  -- Skip non-file buffers (e.g. fugitive:// blame/blob buffers) so gopls
  -- doesn't choke on non-'file' URI schemes.
  root_dir = function(bufnr, on_dir)
    if vim.bo[bufnr].buftype ~= '' then
      return
    end
    on_dir(vim.fs.root(bufnr, { 'go.work', 'go.mod', '.git' }))
  end,
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
