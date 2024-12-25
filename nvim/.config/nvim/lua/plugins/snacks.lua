return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  config = function()
    local Snacks = require('snacks')
    Snacks.setup({
      bigfile = {},
      notifier = {
        icons = {
          error = "Error",
          warn = "Warn",
          info = "Info",
          debug = "Debug",
          trace = "Trace",
        },
      },
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

    -- map('n', '<leader>fn', Snacks.notifier.show_history)
    map('n', '<leader>hn', Snacks.notifier.hide)
  end
}
