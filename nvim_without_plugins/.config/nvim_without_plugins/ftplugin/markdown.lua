local keyset = vim.keymap.set
local keyopts = { buffer = true }

keyset('i', ',n', '<CR>---<CR><CR>', keyopts) -- dashes
keyset('i', ',b', '****<left><left>', keyopts) -- bold
keyset('i', ',s', '~~~~<left><left>', keyopts) -- strikethrough
keyset('i', ',i', '**<left>', keyopts) -- italic
keyset('i', ',d', '``<left>', keyopts) -- code
keyset('i', ',c', '``````<left><left><left>', keyopts) -- code block
keyset('i', ',p', '![]()<left><left><left>', keyopts)
keyset('i', ',1', '# ', keyopts)
keyset('i', ',2', '## ', keyopts)
keyset('i', ',3', '### ', keyopts)
keyset('i', ',4', '#### ', keyopts)
keyset('i', ',5', '##### ', keyopts)
keyset('i', ',6', '###### ', keyopts)

vim.opt_local.wrap = true
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.conceallevel = 0
