local create_autocmd = vim.api.nvim_create_autocmd

-- Line breaks are not automatically commented
create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    vim.cmd('setlocal formatoptions-=c formatoptions-=r formatoptions-=o')
  end
})

-- Highlight when copying
create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.highlight.on_yank()
  end
})

-- Events

create_autocmd({ 'BufReadPost', 'BufWritePost', 'BufNewFile' }, {
  group = vim.api.nvim_create_augroup('FileOpened', { clear = true }),
  pattern = '*',
  callback = function(args)
    vim.api.nvim_exec_autocmds('User', { pattern = 'FileOpened', modeline = false })
  end
})
