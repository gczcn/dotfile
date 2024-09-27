return {
  'fedepujol/move.nvim',
  cmd = { 'MoveLine', 'MoveHChar', 'MoveWord', 'MoveBlock', 'MoveHBlock' },
  keys = {
    { '<M-u>', ':MoveLine(-1)<CR>', mode = 'n', noremap = true, silent = true },
    { '<M-e>', ':MoveLine(1)<CR>', mode = 'n', noremap = true, silent = true },
    { '<M-n>', ':MoveHChar(-1)<CR>', mode = 'n', noremap = true, silent = true },
    { '<M-i>', ':MoveHChar(1)<CR>', mode = 'n', noremap = true, silent = true },
    { '<leader>wf', ':MoveWord(1)<CR>', mode = 'n', noremap = true, silent = true },
    { '<leader>wb', ':MoveWord(-1)<CR>', mode = 'n', noremap = true, silent = true },

    { '<M-u>', ':MoveBlock(-1)<CR>', mode = 'v', noremap = true, silent = true },
    { '<M-e>', ':MoveBlock(1)<CR>', mode = 'v', noremap = true, silent = true },
    { '<M-n>', ':MoveHBlock(-1)<CR>', mode = 'v', noremap = true, silent = true },
    { '<M-i>', ':MoveHBlock(1)<CR>', mode = 'v', noremap = true, silent = true },
  },
  config = function() require('move').setup({ char = { enable = true } }) end
}
