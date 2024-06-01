vim.g.mapleader      = ' '
vim.g.maplocalleader = '\\'

vim.o.timeout    = true
vim.o.timeoutlen = 300

local nv  = { 'n', 'v' }
local nvo = { 'n', 'v', 'o' }
local v   = { 'v' }
local i   = { 'i' }
local ic  = { 'i', 'c' }
local ivc = { 'i', 'v', 'c' }
local c   = { 'c' }
local t   = { 't' }

local nmappings = {
  { from = 'Q',           to = '<cmd>q<CR>' },
  { from = '<M-y>',       to = '"+y',                                                            mode = nv },
  { from = '<M-Y>',       to = '"+Y',                                                            mode = nv },
  { from = '<M-p>',       to = '"+p',                                                            mode = nv },
  { from = '<M-P>',       to = '"+P',                                                            mode = nv },
  { from = 'kr',          to = '`[`]',                                                           mode = v },
  { from = '`',           to = '~<left>' },
  { from = '`',           to = '~',                                                              mode = v },
  { from = '<M-q>',       to = '<ESC>',                                                          mode = ivc },
  { from = '<M-q>',       to = '<C-\\><C-n>',                                                    mode = t },
  { from = '<leader>l',   to = '<cmd>noh<CR>' },

  -- Movement
  { from = 'u',           to = 'k',                                                              mode = nvo },
  { from = 'e',           to = 'j',                                                              mode = nvo },
  { from = 'n',           to = 'h',                                                              mode = nvo },
  { from = 'i',           to = 'l',                                                              mode = nvo },
  { from = 'U',           to = '5k',                                                             mode = nvo },
  { from = 'E',           to = '5j',                                                             mode = nvo },
  { from = 'N',           to = '0',                                                              mode = nvo },
  { from = 'I',           to = '$',                                                              mode = nvo },
  { from = '<M-u>',       to = '<up>',                                                           mode = i },
  { from = '<M-e>',       to = '<down>',                                                         mode = i },
  { from = '<M-n>',       to = '<left>',                                                         mode = ic },
  { from = '<M-i>',       to = '<right>',                                                        mode = ic },
  { from = '<M-U>',       to = '<cmd>normal! 5k<CR>',                                            mode = i },
  { from = '<M-E>',       to = '<cmd>normal! 5j<CR>',                                            mode = i },
  { from = '<M-N>',       to = '<cmd>normal! 0<CR>',                                             mode = i },
  { from = '<M-I>',       to = '<cmd>normal! $<CR><right>',                                      mode = i },
  { from = '<M-N>',       to = '<left><left><left><left><left>',                                 mode = c },
  { from = '<M-I>',       to = '<right><right><right><right><right>',                            mode = c },
  { from = 'h',           to = 'e',                                                              mode = nv },
  { from = 'W',           to = '5w',                                                             mode = nv },
  { from = 'B',           to = '5b',                                                             mode = nv },

  -- Actions
  { from = 'j',           to = 'n',                                                              mode = nvo },
  { from = 'J',           to = 'N',                                                              mode = nvo },
  { from = 'l',           to = 'u',                                                              mode = nv },
  { from = 'L',           to = 'U',                                                              mode = nv },
  { from = 'k',           to = 'i',                                                              mode = nvo },
  { from = 'K',           to = 'I',                                                              mode = nvo },

  -- Move block
  { from = '+',           to = ":m '>+1<CR>gv=gv",                                               mode = v },
  { from = '-',           to = ":m '<-2<CR>gv=gv",                                               mode = v },

  -- Window & splits
  { from = '<leader>ww',  to = '<C-w>w' },
  { from = '<leader>wu',  to = '<C-w>k' },
  { from = '<leader>we',  to = '<C-w>j' },
  { from = '<leader>wn',  to = '<C-w>h' },
  { from = '<leader>wi',  to = '<C-w>l' },
  { from = '<leader>su',  to = '<cmd>set nosplitbelow<CR><cmd>split<CR><cmd>set splitbelow<CR>' },
  { from = '<leader>se',  to = '<cmd>set splitbelow<CR><cmd>split<CR>' },
  { from = '<leader>sn',  to = '<cmd>set nosplitright<CR><cmd>vsplit<CR><cmd>set splitright<CR>' },
  { from = '<leader>si',  to = '<cmd>set splitright<CR><cmd>vsplit<CR>' },
  { from = '<leader>sv',  to = '<C-w>t<C-w>H' },
  { from = '<leader>sh',  to = '<C-w>t<C-w>K' },
  { from = '<leader>srv', to = '<C-w>b<C-w>H' },
  { from = '<leader>srh', to = '<C-w>b<C-w>K' },

  -- Resize
  { from = '<M-u>',       to = '<cmd>resize +2<CR>' },
  { from = '<M-e>',       to = '<cmd>resize -2<CR>' },
  { from = '<M-n>',       to = '<cmd>vertical resize -2<CR>' },
  { from = '<M-i>',       to = '<cmd>vertical resize +2<CR>' },

  -- Buffer
  { from = '<leader>bd',  to = '<cmd>bd<CR>' },

  -- Other
  { from = '<leader>ob',  to = '<cmd>TB<CR>' },   -- toggle background [dark | light]
}

for _, mapping in ipairs(nmappings) do
  vim.keymap.set(mapping.mode or 'n', mapping.from, mapping.to, mapping.opts or { noremap = true })
end
