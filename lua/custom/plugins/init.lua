-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

local function create_plugin(plugin_name)
  return {
    plugin_name,
    opts = {},
    config = function() end,
  }
end

return {
  create_plugin 'ojroques/vim-oscyank', -- Copy from ssh + tmux + docker to clipboard
  create_plugin 'thaerkh/vim-workspace', -- Workspace for nvim, open on where you left at
  --create_plugin 'fatih/vim-go', -- Already have nvim-lspconfig with gopls enabled
  create_plugin 'preservim/nerdcommenter', -- Toggle comment code
  create_plugin 'mtdl9/vim-log-highlighting', -- Highlight log file
  create_plugin 'tpope/vim-fugitive', -- Git blame
}
