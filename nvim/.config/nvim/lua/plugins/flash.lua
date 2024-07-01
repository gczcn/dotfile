return {
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {
      modes = {
        search = {
          enabled = true,
        },
      },
    },
    -- stylua: ignore
    keys = {
      { '<leader>ft', function() require('flash').jump() end, mode = { 'n', 'x', 'o' }, desc = 'Flash' },
      { '<leader>FT', function() require('flash').treesitter() end, mode = { 'n', 'x', 'o' }, desc = 'Flash Treesitter' },
      { '<leader>frt', function() require('flash').remote() end, mode = 'o', desc = 'Remote Flash' },
      { '<leader>FTS', function() require('flash').treesitter_search() end, mode = { 'o', 'x' }, desc = 'Treesitter Search' },
      { '<C-s>', function() require('flash').toggle() end, mode = 'c', desc = 'Toggle Flash Search' },
    },
  }
}
