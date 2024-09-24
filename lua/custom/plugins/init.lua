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
  -- Git plugin
  create_plugin 'tpope/vim-fugitive', -- :Git blame, ...
  create_plugin 'tpope/vim-rhubarb', -- :GBrowse - to open commit url in browser
  create_plugin 'junegunn/gv.vim', -- :GV - to browse git commit history

  -- Workflow
  create_plugin 'ojroques/vim-oscyank', -- Copy from ssh + tmux + docker to clipboard
  create_plugin 'thaerkh/vim-workspace', -- Workspace for nvim, open on where you left at
  create_plugin 'mtdl9/vim-log-highlighting', -- Highlight log file

  -- Coding
  create_plugin 'preservim/tagbar', -- Display class + variable structure of file
  create_plugin 'preservim/nerdcommenter', -- :NERDCommenterToggle - Toggle comment code
  --create_plugin 'fatih/vim-go', -- Already have nvim-lspconfig with gopls enabled
}
