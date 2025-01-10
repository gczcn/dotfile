local api = vim.api
local autocmd = api.nvim_create_autocmd

-- Line breaks are not automatically commented
autocmd('FileType', {
  pattern = '*',
  callback = function()
    vim.cmd('setlocal formatoptions-=c formatoptions-=r formatoptions-=o')
  end
})

-- Highlight when copying
autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.highlight.on_yank()
  end
})

autocmd('User', {
  pattern = 'FileOpened',
  desc = 'Ghostty comfiguration file commentstring',
  callback = function()
    local buf_name = api.nvim_buf_get_name(0)
    local path = require('utils.split')(buf_name, '/')
    if path[3] == '.config' and path[4] == 'ghostty' and path[5] == 'config' then
      vim.bo.commentstring = '#%s'
    end
  end
})

-- https://github.com/sitiom/nvim-numbertoggle/blob/main/plugin/numbertoggle.lua
autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" }, {
   pattern = "*",
   callback = function()
      if vim.o.nu and vim.api.nvim_get_mode().mode ~= "i" then
         vim.opt.relativenumber = true
      end
   end,
})

autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" }, {
   pattern = "*",
   callback = function()
      if vim.o.nu then
         vim.opt.relativenumber = false
         vim.cmd "redraw"
      end
   end,
})

-- Events

autocmd({ 'BufReadPost', 'BufWritePost', 'BufNewFile' }, {
  group = vim.api.nvim_create_augroup('FileOpened', { clear = true }),
  pattern = '*',
  callback = function(args)
    vim.api.nvim_exec_autocmds('User', { pattern = 'FileOpened', modeline = false })
  end
})
