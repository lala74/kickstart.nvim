return {
  {
    'ellisonleao/gruvbox.nvim',
    opts = {},
    config = function()
      require('gruvbox').setup {
        terminal_colors = false, -- true: apply gruvbox for intergrated terminal
        undercurl = true, -- true: undercurl spelling error
        underline = true, -- true: underline for link or ...
        bold = true, -- true: bold for function
        italic = {
          strings = false, -- false: string is not italic
          emphasis = false,
          comments = false, -- false: comment is not italic
          operators = false, -- false: + * is not italic
          folds = false, -- false: folded text is not italic
        },
        strikethrough = true, -- true: enable strikethrough
        invert_selection = false, -- false: nice selection in visual mode
        invert_signs = false, -- false: not invert color for git sign, diagnostic symbol
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true, -- true: inverse color for search, help find result faster
        contrast = '', -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false, -- FALSE: do not dim inactive window
        transparent_mode = false, -- false: do not transparent the background
      }
      vim.cmd.colorscheme 'gruvbox'
    end,
  },
}
