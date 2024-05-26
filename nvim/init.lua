-- Basic settings
require('core.keymaps')
require('core.options')
require('core.commands')
require('core.autocmds')

-- neovide
if vim.g.neovide then
  require('core.neovide')
end

-- Plugins installation and configuration
require('plugins-setup')
