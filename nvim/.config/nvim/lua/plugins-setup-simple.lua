local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { import = 'plugins.just_simple' },
  { import = 'plugins.just_simple.lsp' },
  require('plugins.lsp.mason-lspconfig'),

  require('plugins.lualine'),
  require('plugins.code-runner'),
  require('plugins.flash'),
  require('plugins.indent'),
  require('plugins.markdown-preview'),
  require('plugins.mason'),
  require('plugins.nvim-autopairs'),
}, {
  install = {
    colorscheme = { 'gruvbox', 'habamax' },
  },
})
