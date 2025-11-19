-- ==========
-- Autocmds
-- ==========

local create_autocmd = vim.api.nvim_create_autocmd
local create_augroup = vim.api.nvim_create_augroup

-- Line breaks are not automatically commented
create_autocmd('FileType', {
  group = create_augroup('disable_auto_comment', {}),
  pattern = '*',
  callback = function()
    vim.cmd('setlocal formatoptions-=c formatoptions-=r formatoptions-=o')
  end,
})

-- Highlight when copying
---@diagnostic disable-next-line: param-type-mismatch
create_autocmd('TextYankPost', {
  group = create_augroup('highlight_yanking_text', {}),
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.highlight.on_yank()
  end,
})
