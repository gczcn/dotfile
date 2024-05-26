return {
  {
    'tomasky/bookmarks.nvim',
    event = 'VeryLazy',
    config = function()
      require('bookmarks').setup({
        -- sign_priority = 8,  --set bookmark sign priority to cover other sign
        save_file = vim.fn.expand('$HOME/.bookmarks'), -- bookmarks save file path
        keywords = {
          ['@t'] = 'BT', -- mark annotation startswith @t ,signs this icon as `Todo`
          ['@w'] = 'BW', -- mark annotation startswith @w ,signs this icon as `Warn`
          ['@f'] = 'BF', -- mark annotation startswith @f ,signs this icon as `Fix`
          ['@n'] = 'BN', -- mark annotation startswith @n ,signs this icon as `Note`
          ['@c'] = 'BC', -- mark annotation startswith @c ,signs this icon as `Config`
          ['@o'] = 'B.', -- mark annotation startswith @o ,signs this icon as `Other`
        },
        on_attach = function(bufnr)
          local bm = require('bookmarks')
          local map = vim.keymap.set
          map('n', '<leader>mm',bm.bookmark_toggle) -- add or remove bookmark at current line
          map('n', '<leader>mi', bm.bookmark_ann) -- add or edit mark annotation at current line
          map('n', '<leader>mc', bm.bookmark_clean) -- clean all marks in local buffer
          map('n', '<leader>mn', bm.bookmark_next) -- jump to next mark in local buffer
          map('n', '<leader>mp', bm.bookmark_prev) -- jump to previous mark in local buffer
          map('n', '<leader>ml', bm.bookmark_list) -- show marked file list in quickfix window
        end,
      })
    end,
  }
}
