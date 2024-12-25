return {
  'ibhagwan/fzf-lua',
  dependencies = {
    'echasnovski/mini.icons',
    'nvim-treesitter/nvim-treesitter-context',
  },
  cmd = 'FzfLua',
  keys = {
    { '<leader>ff', '<cmd>FzfLua files<CR>' },
    { '<leader>fr', '<cmd>FzfLua oldfiles<CR>' },
    { '<leader>fs', '<cmd>FzfLua live_grep<CR>' },
    { '<leader>fc', '<cmd>FzfLua grep<CR>' },
    { '<leader>fk', '<cmd>FzfLua keymaps<CR>' },
    { '<leader>fh', '<cmd>FzfLua helptags<CR>' },
    { '<leader>fo', string.format('<cmd>FzfLua files cwd=%s<CR>', vim.fn.stdpath('config')) },
    { '<leader>fb', '<cmd>FzfLua buffers<CR>' },
  },
  config = function()
    require('fzf-lua').setup({
      winopts = {
        border = 'single',
        backdrop = 100,
        on_create = function()
          vim.keymap.set('t', '<M-e>', '<down>', { silent = true, buffer = true })
          vim.keymap.set('t', '<M-u>', '<up>', { silent = true, buffer = true })
        end,
      },
    })
  end
}
