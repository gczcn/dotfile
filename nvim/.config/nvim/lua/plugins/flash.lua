return {
  'folke/flash.nvim',
  enabled = true,
  event = 'VeryLazy',
  ---@type Flash.Config
  opts = {
    -- labels = 'asdfghjklqwertyuiopzxcvbnm',
    labels = 'arstdhneiqwfpgjluy;zxcvbkm', -- Colemak
    prompt = {
      prefix = { { ' Jump ', 'FlashPromptIcon' } },
    },
  },
  -- stylua: ignore
  keys = {
    { '<leader>/', function() require('flash').jump() end, mode = { 'n', 'x', 'o', 'v' }, desc = 'Flash' },
    { '<leader>?', function() require('flash').treesitter() end, mode = { 'n', 'x', 'o', 'v' }, desc = 'Flash Treesitter' },
    { '<leader>\\', function() require('flash').remote() end, mode = 'o', desc = 'Remote Flash' },
    { '<leader>|', function() require('flash').treesitter_search() end, mode = { 'o', 'x', 'v' }, desc = 'Treesitter Search' },
    { '<C-s>', function() require('flash').toggle() end, mode = 'c', desc = 'Toggle Flash Search' },
  },
}
