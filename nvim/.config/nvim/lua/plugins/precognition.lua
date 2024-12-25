return {
  'tris203/precognition.nvim',
  event = { 'VeryLazy', 'User FileOpened', 'BufAdd' },
  keys = {
    { '<leader>ap', '<cmd>Precognition peek<CR>', mode = 'n' }
  },
  opts = {
    startVisible = false,
    highlightColor = { link = 'Comment' },
    hints = {
      Caret = { text = '|' },
      Dollar = { text = 'I' },
      Zero = { text = 'N' },
      e = { text = 'h' },
      E = { text = 'H' },
    },
  },
}
