local M = {}

M.setup = function(mode)
  if mode ~= 'default' and mode ~= 'simple' and mode ~= 'clean' then
    vim.notify(('\nThere is no mode named "%s", starting with the "default" mode\n'):format(mode), vim.log.levels.ERROR)
    mode = 'default'
  end

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
  if mode == 'default' then
    require('plugins-setup-default')
  end

  if mode == 'simple' then
    require('plugins-setup-simple')
  end
end

return M
