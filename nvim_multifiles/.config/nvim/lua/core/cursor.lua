-- https://github.com/theniceboy/nvim/blob/master/cursor.vim
local map = vim.keymap.set
local opts = { noremap = true }

local keyboard = { 'o', 'a', 'r', 's', 't', 'd', 'h', 'n', 'e', 'i' }

local keys = ''
local number = ''
for i = 1, 199 do
  number = tostring(i)
  keys = ''
  for j = 1, #number do
    keys = keys .. keyboard[tonumber(string.sub(number, j, j)) + 1]
  end
  map({ 'n', 'v', 'o' }, "'" .. keys .. '<leader>', number .. 'j', opts)
  map({ 'n', 'v', 'o' }, '[' .. keys .. '<leader>', number .. 'k', opts)
end
