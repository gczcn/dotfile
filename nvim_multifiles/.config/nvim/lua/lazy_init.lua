-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.opt.cmdheight = 0
vim.opt.laststatus = 0
vim.opt.winblend = 15
vim.opt.pumblend = 15
vim.opt.signcolumn = 'auto'
vim.o.foldcolumn = '1' -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- vim.diagnostic.config({ virtual_text = { prefix = '󰝤' } })

vim.keymap.set('n', '<leader>ls', '<cmd>Lazy sync<CR>', { noremap = true })
vim.keymap.set('n', '<leader>tl', function()
  if vim.o.filetype == 'lazy' then
    vim.cmd.q()
  else
    vim.cmd.Lazy()
  end
end)

-- Setup lazy.nvim
require('lazy').setup({
  spec = {
    { import = 'plugins' },
    { import = 'plugins.lsp' },
    { import = 'plugins.local' },
  },
  install = { colorscheme = { 'gruvbox', 'gruvbox-material', 'catppuccin', 'tokyonight', 'habamax' } },

  -- ui = {
  --   backdrop = 100,
  --   border = 'single',
  -- },

  -- automatically check for plugin updates
  checker = {
    enabled = true,
  },
  change_detection = {
    notify = false,
  },

  performance = {
    rtp = {
      disabled_plugins = {
        'netrwPlugin',
      },
    },
  },
})
