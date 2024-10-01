return {
  'lambdalisue/vim-suda',
  config = function()
    vim.cmd.cabbrev('ww SudaWrite')
    vim.cmd.cabbrev('wwr SudaRead')
  end,
}
