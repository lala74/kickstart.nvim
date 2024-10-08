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
  require 'custom.plugins.theme',
  require 'custom.plugins.ai',

  -- Git plugin
  create_plugin 'tpope/vim-fugitive', -- :Git blame, ...
  create_plugin 'tpope/vim-rhubarb', -- :GBrowse - to open commit url in browser
  create_plugin 'junegunn/gv.vim', -- :GV - to browse git commit history

  -- Coding
  create_plugin 'preservim/tagbar', -- Display class + variable structure of file
  create_plugin 'preservim/nerdcommenter', -- :NERDCommenterToggle - Toggle comment code

  -- Workflow
  create_plugin 'ojroques/vim-oscyank', -- Copy from ssh + tmux + docker to clipboard
  create_plugin 'mtdl9/vim-log-highlighting', -- Highlight log file
  create_plugin 'mg979/vim-visual-multi', -- Testing: Multiple select like vscode
  {
    'rmagatti/auto-session',
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      -- log_level = 'debug',
    },
  },

  -- Searching
  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- calling `setup` is optional for customization
      local fzflua = require 'fzf-lua'
      local fzf_actions = require 'fzf-lua.actions'
      fzflua.setup {
        'telescope',
        winopts = {
          preview = {
            layout = 'vertical',
            vertical = 'up:65%',
            wrap = 'wrap',
            winopts = { number = true },
          },
        },
      }

      vim.keymap.set('n', '<leader>sh', fzflua.helptags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', fzflua.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', fzflua.files, { desc = '[S]earch [F]ile' })
      vim.keymap.set('n', '<leader>ss', fzflua.builtin, { desc = '[S]earch [S]elect Fzf' })
      vim.keymap.set('n', '<leader>sw', fzflua.grep_cword, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', fzflua.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sr', fzflua.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>sc', fzflua.colorschemes, { desc = '[S]earch [C]olorscheme' })
      vim.keymap.set('n', '<C-f>', fzflua.live_grep, { desc = '[S]earch by [G]rep' })
    end,
  },
}
