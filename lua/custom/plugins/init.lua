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

  -- Coding
  create_plugin 'preservim/tagbar', -- Display class + variable structure of file
  create_plugin 'preservim/nerdcommenter', -- :NERDCommenterToggle - Toggle comment code
  --create_plugin 'fatih/vim-go', -- Already have nvim-lspconfig with gopls enabled

  -- Workflow
  create_plugin 'ojroques/vim-oscyank', -- Copy from ssh + tmux + docker to clipboard
  create_plugin 'mtdl9/vim-log-highlighting', -- Highlight log file
  create_plugin 'mg979/vim-visual-multi', -- Testing: Multiple select like vscode
  {
    -- Workspace for nvim, open on where you left at
    'thaerkh/vim-workspace',
    opts = {},
    config = function()
      vim.g.workspace_autocreate = 1 -- autocreate workspace when open new file
      vim.g.workspace_autosave = 0 -- disable auto save on InsertLeave
    end,
  },
  {
    'github/copilot.vim',
    opts = {},
    config = function() end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    dependencies = {
      { 'github/copilot.vim' }, -- or github/copilot.vim
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
