local autocmd = vim.api.nvim_create_autocmd

-- Line breaks are not automatically commented
autocmd('FileType', {
  pattern = '*',
  callback = function ()
    vim.cmd('setlocal formatoptions-=c formatoptions-=r formatoptions-=o')
  end
})

-- Highlight when copying
autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function ()
    vim.highlight.on_yank()
  end
})

autocmd('FileType', {
  pattern = { 'json', 'lsonc', 'markdown' },
  callback = function()
    vim.wo.conceallevel = 0
  end
})

autocmd('FileType', {
  pattern = { 'markdown' },
  callback = function()
    vim.o.shiftwidth = 2
  end
})

-- Events

autocmd({ 'BufReadPost', 'BufWritePost', 'BufNewFile' }, {
  group = vim.api.nvim_create_augroup('FileOpened', { clear = true }),
  pattern = '*',
  callback = function(args)
    vim.api.nvim_exec_autocmds('User', { pattern = 'FileOpened', modeline = false })
  end
})
