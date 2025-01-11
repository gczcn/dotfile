-- I don't know how to use range.
-- It just works...
local translate = function(t, to)
  vim.cmd.split()
  local text = t
  text = string.gsub(text, '"', '"' .. "'" .. '"' .. "'" .. '"')
  text = string.gsub(text, '\\', '\\\\')
  vim.cmd.term('trans :' .. to .. ' "' .. text .. '"')

  vim.keymap.set('n', 'q', '<cmd>bd<CR>', { buffer = true })
end

vim.api.nvim_create_user_command('Translate', function(opts)
  local text = vim.fn.getreg('t')
  translate(text, opts.args)
end, {
  range = true,
  nargs = 1,
})

vim.keymap.set('v', '<leader>tr', '"ty<cmd>Translate zh<CR>', { noremap = true })
