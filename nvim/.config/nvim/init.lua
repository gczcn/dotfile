require('core.keymaps')
require('core.cursor')
require('core.options')
require('core.commands')
require('core.autocmds')
require('core.gui')

require('functions.translate_shell')

-- Neovide (a neovim GUI client)
if vim.g.neovide then
  require('core.neovide')
end

-- Plugins
require('lazy_init')
