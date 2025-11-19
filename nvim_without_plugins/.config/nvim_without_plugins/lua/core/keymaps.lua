-- ==================================================
-- Basic Keymap Settings
-- This file sets all basic keymaps except for LSP.
-- ==================================================

local keyset = vim.keymap.set
local opts = { noremap = true }

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Movement
keyset({ 'n', 'v', 'o' }, 'u', 'k', opts)
keyset({ 'n', 'v', 'o' }, 'e', 'j', opts)
keyset({ 'n', 'v', 'o' }, 'n', 'h', opts)
keyset({ 'n', 'v', 'o' }, 'i', 'l', opts)
keyset({ 'n', 'v', 'o' }, 'N', '0', opts)
keyset({ 'n', 'v', 'o' }, 'I', '$', opts)

keyset({ 'n', 'v', 'o' }, 'j', 'n', opts)
keyset({ 'n', 'v', 'o' }, 'J', 'N', opts)
keyset({ 'n', 'v', 'o' }, 'h', 'e', opts)
keyset({ 'n', 'v', 'o' }, 'H', 'E', opts)
keyset({ 'n', 'v', 'o' }, '|', '^', opts)

-- Actions
keyset({ 'n', 'v' }, 'E', 'J', opts)
keyset({ 'n', 'v' }, 'l', 'u', opts)
keyset({ 'n', 'v' }, 'L', 'U', opts)
keyset({ 'n', 'v', 'o' }, 'k', 'i', opts)
keyset({ 'n', 'v', 'o' }, 'K', 'I', opts)
keyset('t', '<M-q>', '<C-\\><C-n>', opts)
keyset({ 'n', 'v', 'o' }, '0', '`', opts)
keyset({ 'n', 'v', 'o' }, '`', 'q:a', opts)

-- Indenting
keyset('v', '<', '<gv', opts)
keyset('v', '>', '>gv', opts)

-- Windows & Splits
keyset('n', '<leader>ww', '<C-w>w', opts)
keyset('n', '<leader>wu', '<C-w>k', opts)
keyset('n', '<leader>we', '<C-w>j', opts)
keyset('n', '<leader>wn', '<C-w>h', opts)
keyset('n', '<leader>wi', '<C-w>l', opts)
keyset('n', '<leader>su', '<cmd>set nosb | split | set sb<CR>', opts)
keyset('n', '<leader>se', '<cmd>set sb | split<CR>', opts)
keyset('n', '<leader>sn', '<cmd>set nospr | vsplit | set spr<CR>', opts)
keyset('n', '<leader>si', '<cmd>set spr | vsplit<CR>', opts)
keyset('n', '<leader>sv', '<C-w>t<C-w>H', opts)
keyset('n', '<leader>sh', '<C-w>t<C-w>K', opts)
keyset('n', '<leader>srv', '<C-w>b<C-w>H', opts)
keyset('n', '<leader>srh', '<C-w>b<C-w>K', opts)

-- Resize
keyset('n', '<M-up>', '<cmd>resize +5<CR>', opts)
keyset('n', '<M-down>', '<cmd>resize -5<CR>', opts)
keyset('n', '<M-left>', '<cmd>vertical resize -10<CR>', opts)
keyset('n', '<M-right>', '<cmd>vertical resize +10<CR>', opts)

-- Commenting
keyset('n', 'gcO', function()
  require('utils.commenting').newline('O')
end, { desc = 'Add comment on the line above', silent = true })
keyset('n', 'gco', function()
  require('utils.commenting').newline('o')
end, { desc = 'Add comment on the line below', silent = true })
keyset('n', 'gcA', function()
  require('utils.commenting').line_end()
end, { desc = 'Add comment at the end of line', silent = true })
keyset('n', 'gcc', function()
  require('utils.commenting').toggle_line()
end, { desc = 'Toggle comment line', silent = true })

-- Copy and Paste
keyset({ 'n', 'v' }, '<M-y>', '"+y', opts)
keyset({ 'n', 'v' }, '<M-Y>', '"+Y', opts)
keyset({ 'n', 'v' }, '<M-p>', '"+p', opts)
keyset({ 'n', 'v' }, '<M-P>', '"+P', opts)
keyset({ 'n', 'v' }, '<M-d>', '"+d', opts)
keyset({ 'n', 'v' }, '<M-D>', '"+D', opts)
keyset('o', '<M-y>', 'y', opts)
keyset('o', '<M-Y>', 'Y', opts)
keyset('o', '<M-d>', 'd', opts)
keyset('o', '<M-D>', 'D', opts)

-- Buffer
keyset('n', '<leader>bd', '<cmd>bd<CR>', opts)

-- Other
keyset({ 'n', 'v' }, '<F5>', function()
  vim.opt.background = vim.o.background == 'dark' and 'light' or 'dark'
end, opts)
keyset('n', '<leader>tc', function()
  vim.opt.cursorcolumn = not vim.o.cursorcolumn
end, opts)
keyset('n', '<leader>l', '<cmd>noh<CR>', opts)
keyset('n', '<leader>fn', '<cmd>messages<CR>', opts)
keyset(
  'n',
  '<leader>oo',
  '<cmd>e ' .. vim.fn.stdpath('config') .. '/init.lua<CR>'
)
keyset('n', 'gX', function()
  vim.ui.open('https://github.com/' .. vim.fn.expand('<cfile>'))
end)
keyset(
  'n',
  '<leader><leader>',
  '<cmd>lua vim.diagnostic.config({virtual_lines=not vim.diagnostic.config().virtual_lines})<CR>'
)

-- Sth about LSP keymaps:
-- you can find LSP keymaps from core/lsp.lua file
