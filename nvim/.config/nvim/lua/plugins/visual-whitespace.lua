return {
  'mcauley-penney/visual-whitespace.nvim',
  event = 'VeryLazy',
  config = function()
    local get_hl = require('utils.get_hl')
    require('visual-whitespace').setup({
      highlight = { fg = get_hl('Comment'), bg = get_hl('Visual', true) },
    })
  end,
}
