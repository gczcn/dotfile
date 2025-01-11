return {
  'fedepujol/move.nvim',
  cmd = { 'MoveLine', 'MoveHChar', 'MoveWord', 'MoveBlock', 'MoveHBlock' },
  keys = {
    { '-', ':MoveLine(-1)<CR>', mode = 'n', noremap = true, silent = true },
    { '+', ':MoveLine(1)<CR>', mode = 'n', noremap = true, silent = true },
    { '<C-n>', ':MoveHChar(-1)<CR>', mode = 'n', noremap = true, silent = true },
    { '<C-i>', ':MoveHChar(1)<CR>', mode = 'n', noremap = true, silent = true },
    { '<leader>wf', ':MoveWord(1)<CR>', mode = 'n', noremap = true, silent = true },
    { '<leader>wb', ':MoveWord(-1)<CR>', mode = 'n', noremap = true, silent = true },

    { '-', ':MoveBlock(-1)<CR>', mode = 'v', noremap = true, silent = true },
    { '+', ':MoveBlock(1)<CR>', mode = 'v', noremap = true, silent = true },
    { '<C-n>', ':MoveHBlock(-1)<CR>', mode = 'v', noremap = true, silent = true },
    { '<C-i>', ':MoveHBlock(1)<CR>', mode = 'v', noremap = true, silent = true },
  },
  config = function() require('move').setup({ char = { enable = true } }) end
}
