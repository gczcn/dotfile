local map = vim.keymap.set
---@type { [string]: boolean }
local opts = { noremap = true, silent = true }
local keyboard_layout = GlobalConfig.keyboard_layout
local middle_row_of_keyboard = GlobalConfig.middle_row_of_keyboard[keyboard_layout]

vim.g.mapleader = ' '

-- Movement
if keyboard_layout == 'colemak' then
	map({ 'n', 'v', 'o' }, 'u', 'k', opts)
	map({ 'n', 'v', 'o' }, 'e', 'j', opts)
	map({ 'n', 'v', 'o' }, 'n', 'h', opts)
	map({ 'n', 'v', 'o' }, 'i', 'l', opts)
	map({ 'n', 'v', 'o' }, 'N', '0', opts)
	map({ 'n', 'v', 'o' }, 'I', '$', opts)

	map({ 'n', 'v', 'o' }, 'j', 'n', opts)
	map({ 'n', 'v', 'o' }, 'J', 'N', opts)
	map({ 'n', 'v', 'o' }, 'h', 'e', opts)
	map({ 'n', 'v', 'o' }, 'H', 'E', opts)
end
map({ 'n', 'v', 'o' }, '|', '^', opts)

-- Actions
if keyboard_layout == 'colemak' then
	map({ 'n', 'v' }, 'E', 'J', opts)
	map({ 'n', 'v' }, 'l', 'u', opts)
	map({ 'n', 'v' }, 'L', 'U', opts)
	map({ 'n', 'v', 'o' }, 'k', 'i', opts)
	map({ 'n', 'v', 'o' }, 'K', 'I', opts)
	map('v', 'kr', '`[`]', opts)
elseif keyboard_layout == 'qwerty' then
	map('v', 'ir', '`[`]', opts)
end
map('t', '<M-q>', '<C-\\><C-n>', opts)

-- Windows & Splits
if keyboard_layout == 'colemak' then
	map('n', '<leader>ww', '<C-w>w', opts)
	map('n', '<leader>wu', '<C-w>k', opts)
	map('n', '<leader>we', '<C-w>j', opts)
	map('n', '<leader>wn', '<C-w>h', opts)
	map('n', '<leader>wi', '<C-w>l', opts)
	map('n', '<leader>su', '<cmd>set nosb | split | set sb<CR>', opts)
	map('n', '<leader>se', '<cmd>set sb | split<CR>', opts)
	map('n', '<leader>sn', '<cmd>set nospr | vsplit | set spr<CR>', opts)
	map('n', '<leader>si', '<cmd>set spr | vsplit<CR>', opts)
elseif keyboard_layout == 'qwerty' then
	map('n', '<leader>ww', '<C-w>w', opts)
	map('n', '<leader>wk', '<C-w>k', opts)
	map('n', '<leader>wj', '<C-w>j', opts)
	map('n', '<leader>wh', '<C-w>h', opts)
	map('n', '<leader>wl', '<C-w>l', opts)
	map('n', '<leader>sk', '<cmd>set nosb | split | set sb<CR>', opts)
	map('n', '<leader>sj', '<cmd>set sb | split<CR>', opts)
	map('n', '<leader>sh', '<cmd>set nospr | vsplit | set spr<CR>', opts)
	map('n', '<leader>sl', '<cmd>set spr | vsplit<CR>', opts)
end
map('n', '<leader>sv', '<C-w>t<C-w>H', opts)
map('n', '<leader>sh', '<C-w>t<C-w>K', opts)
map('n', '<leader>srv', '<C-w>b<C-w>H', opts)
map('n', '<leader>srh', '<C-w>b<C-w>K', opts)

-- Resize
map('n', '<M-up>', '<cmd>resize +5<CR>', opts)
map('n', '<M-down>', '<cmd>resize -5<CR>', opts)
map('n', '<M-left>', '<cmd>vertical resize -10<CR>', opts)
map('n', '<M-right>', '<cmd>vertical resize +10<CR>', opts)

-- Commenting
local commenting = require('utils.commenting')
map('n', 'gcc', function() commenting.toggle_line() end, { desc = 'Toggle comment line' })
map('n', 'gco', function() commenting.below() end, { desc = 'Add comment on the line below' })
map('n', 'gcO', function() commenting.above() end, { desc = 'Add comment on the line above' })
map('n', 'gcA', function() commenting.line_end() end, { desc = 'Add comment at the end of line' })

-- Copy and Paste
map({ 'n', 'v' }, '<M-y>', '"+y', opts)
map({ 'n', 'v' }, '<M-Y>', '"+Y', opts)
map({ 'n', 'v' }, '<M-p>', '"+p', opts)
map({ 'n', 'v' }, '<M-P>', '"+P', opts)
map({ 'n', 'v' }, '<M-d>', '"+d', opts)
map({ 'n', 'v' }, '<M-D>', '"+D', opts)
map('o', '<M-y>', 'y', opts)
map('o', '<M-Y>', 'Y', opts)
map('o', '<M-d>', 'd', opts)
map('o', '<M-D>', 'D', opts)

-- Buffer
map('n', '<leader>bd', '<cmd>bd<CR>', opts)

-- Cursor
local keys = ''
local number = ''
for i = 1, 199 do
	number = tostring(i)
	keys = ''
	for j = 1, #number do
		keys = keys .. middle_row_of_keyboard[tonumber(string.sub(number, j, j)) + 1]
	end
	map({ 'n', 'v', 'o' }, "'" .. keys .. '<leader>', number .. 'j', opts)
	map({ 'n', 'v', 'o' }, '[' .. keys .. '<leader>', number .. 'k', opts)
end
