return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    branch = 'master',
    cmd = 'Telescope',
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<CR>' },
      { '<leader>fr', '<cmd>Telescope oldfiles<CR>' },
      { '<leader>fs', '<cmd>Telescope live_grep<CR>' },
      { '<leader>fc', '<cmd>Telescope grep_string<CR>' },
      { '<leader>fk', '<cmd>Telescope keymaps<CR>' },
      { '<leader>fh', '<cmd>Telescope help_tags<CR>' },
      { '<leader>fo', '<cmd>Telescope find_files cwd=' .. vim.fn.stdpath 'config' .. '<CR>' },
      { '<leader>fb', '<cmd>Telescope buffers<CR>' },
      { '<leader>fw', '<cmd>Telescope colorscheme' },
    },
  }
}
