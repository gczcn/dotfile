return {
  'petertriho/nvim-scrollbar',
  event = 'VeryLazy',
  config = function()
    require('scrollbar').setup({
      marks = {
        Cursor = {
          text = '█'
        },
      },
      excluded_filetypes = {
        'blink-cmp-menu',
      },
    })
    if vim.g.colors_name == 'gruvbox' then
      local palette = require('gruvbox').palette
      vim.api.nvim_set_hl(0, 'ScrollbarHandle', { bg = palette.dark2, fg = palette.dark4 })
      vim.api.nvim_set_hl(0, 'ScrollbarCursor', { bg = palette.dark2, fg = palette.dark4 })
      vim.api.nvim_set_hl(0, 'ScrollbarCursorHandle', { bg = palette.dark2, fg = palette.dark4 })
    else
      vim.api.nvim_set_hl(0, 'ScrollbarHandle', { link = 'Pmenu' })
    end
  end
}
