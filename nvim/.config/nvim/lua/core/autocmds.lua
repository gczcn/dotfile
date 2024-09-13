local create_autocmd = vim.api.nvim_create_autocmd

-- Line breaks are not automatically commented
create_autocmd('FileType', {
  pattern = '*',
  callback = function ()
    vim.cmd('setlocal formatoptions-=c formatoptions-=r formatoptions-=o')
  end
})

-- Highlight when copying
create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function ()
    vim.highlight.on_yank()
  end
})

-- Do not simplify some file contents
create_autocmd('FileType', {
  pattern = { 'json', 'jsonc', 'json5', 'lsonc', 'markdown' },
  callback = function()
    vim.wo.conceallevel = 0
  end
})

-- Change the tab key in the markdown file to 2 spaces
create_autocmd('FileType', {
  pattern = { 'markdown' },
  callback = function()
    vim.o.shiftwidth = 2
  end
})
