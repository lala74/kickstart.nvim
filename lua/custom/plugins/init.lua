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
  -- Colorscheme
  create_plugin 'ellisonleao/gruvbox.nvim',

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
    -- Workspace for nvim, open on where you left at
    'thaerkh/vim-workspace',
    opts = {},
    config = function()
      vim.g.workspace_autocreate = 0 -- don't autocreate workspace when open new file
      vim.g.workspace_autosave = 0 -- disable auto save on InsertLeave
    end,
  },
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
            vertical = 'up:75%',
            winopts = { number = true },
          },
        },
        lsp = {
          jump_to_single_result = true,
          jump_to_single_result_action = fzf_actions.file_edit,
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

  -- AI
  {
    'zbirenbaum/copilot.lua',
    opts = {},
    config = function()
      require('copilot').setup {
        suggestion = { enabled = false },
        panel = { enabled = false },
      }
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    config = function()
      require('copilot_cmp').setup()
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- or github/copilot.vim
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      -- add any opts here
      provider = 'copilot',
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = 'make',
    -- build = "" -- for windows
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },
}
