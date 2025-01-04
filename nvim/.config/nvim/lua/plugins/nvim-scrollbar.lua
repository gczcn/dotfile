return {
  'petertriho/nvim-scrollbar',
  event = 'VeryLazy',
  config = function()
    require('scrollbar').setup({
      excluded_filetypes = {
        'blink-cmp-menu',
      },
    })
    require('scrollbar').setup({})
    vim.api.nvim_set_hl(0, 'ScrollbarHandle', { link = 'Pmenu' })
  end
}
