return {
  {
    'gczcn/antonym.nvim',
    cmd = 'AntonymWord',
    keys = {
      { '<leader>oa', '<cmd>AntonymWord<CR>' },
    },
    config = function()
      require('antonym').setup()
    end
  }
}
