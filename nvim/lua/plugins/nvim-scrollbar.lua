return {
  {
    'petertriho/nvim-scrollbar',
    event = 'VeryLazy',
    config = function()
      require('scrollbar').setup({
        marks = {
          Cursor = {
            text = '█'
          },
        },
      })
    end
  }
}
