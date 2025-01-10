local map = vim.keymap.set
local opts = { noremap = true }

vim.g.mapleader = ' '

vim.o.timeoutlen = 300

-- Movement
map({ 'n', 'v', 'o' }, 'u', 'gk', opts)
map({ 'n', 'v', 'o' }, 'e', 'gj', opts)
map({ 'n', 'v', 'o' }, 'n', 'h', opts)
map({ 'n', 'v', 'o' }, 'i', 'l', opts)
map({ 'n', 'v', 'o' }, 'N', '0', opts)
map({ 'n', 'v', 'o' }, 'I', '$', opts)

map({ 'n', 'v', 'o' }, 'j', 'n', opts)
map({ 'n', 'v', 'o' }, 'J', 'N', opts)
map({ 'n', 'v', 'o' }, 'h', 'e', opts)
map({ 'n', 'v', 'o' }, 'H', 'E', opts)
map({ 'n', 'v', 'o' }, '|', '^', opts)

-- map({ 'i', 'c' }, '<M-u>', '<up>', opts)
-- map({ 'i', 'c' }, '<M-e>', '<down>', opts)
-- map({ 'i', 'c' }, '<M-n>', '<left>', opts)
-- map({ 'i', 'c' }, '<M-i>', '<right>', opts)
-- map({ 'i', 'c' }, '<M-N>', '<cmd>normal! 0<CR>', opts)
-- map({ 'i', 'c' }, '<M-I>', '<cmd>normal! $<CR><right>', opts)

-- Actions
map({ 'n', 'v' }, 'E', 'J', opts)
map({ 'n', 'v' }, 'l', 'u', opts)
map({ 'n', 'v' }, 'L', 'U', opts)
map({ 'n', 'v', 'o' }, 'k', 'i', opts)
map({ 'n', 'v', 'o' }, 'K', 'I', opts)
-- map('i', 'ii', '<ESC>', opts)
map('t', '<M-q>', '<C-\\><C-n>', opts) -- In terminal change mode to normal

map('v', 'kr', '`[`]', opts)

-- Windows & Splits
map('n', '<leader>ww', '<C-w>w', opts)
map('n', '<leader>wu', '<C-w>k', opts)
map('n', '<leader>we', '<C-w>j', opts)
map('n', '<leader>wn', '<C-w>h', opts)
map('n', '<leader>wi', '<C-w>l', opts)
map('n', '<leader>su', '<cmd>set nosb | split | set sb<CR>', opts)
map('n', '<leader>se', '<cmd>set sb | split<CR>', opts)
map('n', '<leader>sn', '<cmd>set nospr | vsplit | set spr<CR>', opts)
map('n', '<leader>si', '<cmd>set spr | vsplit<CR>', opts)
map('n', '<leader>sv', '<C-w>t<C-w>H', opts)
map('n', '<leader>sh', '<C-w>t<C-w>K', opts)
map('n', '<leader>srv', '<C-w>b<C-w>H', opts)
map('n', '<leader>srh', '<C-w>b<C-w>K', opts)

-- Resize
map('n', '<M-U>', '<cmd>resize +5<CR>', opts)
map('n', '<M-E>', '<cmd>resize -5<CR>', opts)
map('n', '<M-N>', '<cmd>vertical resize -10<CR>', opts)
map('n', '<M-I>', '<cmd>vertical resize +10<CR>', opts)

-- Copy and Paste
map({ 'n', 'v' }, '<M-y>', '"+y', opts)
map({ 'n', 'v' }, '<M-Y>', '"+Y', opts)
map({ 'n', 'v' }, '<M-p>', '"+p', opts)
map({ 'n', 'v' }, '<M-P>', '"+P', opts)
map({ 'n', 'v' }, '<M-d>', '"+d', opts)
map({ 'n', 'v' }, '<M-D>', '"+D', opts)

-- Buffer
map('n', '<leader>bd', '<cmd>bd<CR>', opts)

-- Other
map({ 'n', 'v' }, 'U', 'K', opts) -- Help
map('n', '\\', '<cmd>w<CR>', opts) -- Save
map('n', '<leader>hh', '<cmd>noh<CR>', opts)
map('n', '<leader>aoc', function()
  vim.o.cursorcolumn = not vim.o.cursorcolumn
end)
map({ 'n', 'v' }, '<F5>', function() -- Toggle background [ dark | light ]
  vim.o.background = vim.o.background == 'dark' and 'light' or 'dark'
end, opts)
