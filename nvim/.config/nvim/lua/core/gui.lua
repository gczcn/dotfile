local font = 'JetBrainsMonoMod Nerd Font Mono'
local font_size = 12

local change_font_size = function(n)
  font_size = font_size + n
  vim.o.guifont = font .. ':h' .. font_size
  print(font_size)
end

vim.o.guifont = font .. ':h' .. font_size

vim.keymap.set('n', '<C-=>', function() change_font_size(1) end)
vim.keymap.set('n', '<C-->', function() change_font_size(-1) end)