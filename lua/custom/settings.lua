vim.api.nvim_create_autocmd('User', {
  pattern = 'TelescopePreviewerLoaded',
  callback = function(args)
    vim.wo.wrap = true
  end,
})

-- Not install gopls but use system gopls, manage by go install 'golang.org/x/tools/gopls@<version>' command
require('lspconfig')['gopls'].setup {}
