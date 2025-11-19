-- ===========================================
-- My Neovim Configuration (Without Plugins)
-- https://github.com/gczcn/dotfile/
-- Author: Zixuan Chu <494353540@qq.com>
-- ===========================================

-- This configuration only works with Neovim 0.12.0 and above, so...
if vim.fn.has('nvim-0.12.0') == 0 then
  vim.notify(
    'This configuration only works with Neovim 0.12.0 and above. Please update your Neovim',
    vim.log.levels.ERROR
  )
  return
end

require('core.keymaps')
require('core.options')
require('core.autocmds')
require('core.commands')
require('core.lsp')

require('features')
