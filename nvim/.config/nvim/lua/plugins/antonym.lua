return {
  'gczcn/antonym.nvim',
  cmd = 'AntonymWord',
  keys = {
    { '<leader>ta', '<cmd>AntonymWord<CR>' },
  },
  config = function()
    require('antonym').setup()
  end
}
