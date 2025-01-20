return {
  'lambdalisue/vim-suda',
  event = { 'VeryLazy', 'User FileOpened' },
  cmd = { 'SudaWrite', 'SudaRead' },
  config = function()
    vim.cmd.cabbrev('ww SudaWrite')
    vim.cmd.cabbrev('wwr SudaRead')
  end,
}
