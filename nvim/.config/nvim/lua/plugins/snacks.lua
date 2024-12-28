return {
  'folke/snacks.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    local Snacks = require('snacks')
    Snacks.setup({
      bigfile = {},
      notifier = {},
      styles = {
        notification = { border = 'single' },
        notification_history = {
          border = 'none',
          keys = {
            q = 'close',
            ['<ESC>'] = 'close',
          }
        },
      },
    })

    local map = vim.keymap.set

    map('n', '<leader>fn', Snacks.notifier.show_history)
    map('n', '<leader>hn', Snacks.notifier.hide)
  end
}
