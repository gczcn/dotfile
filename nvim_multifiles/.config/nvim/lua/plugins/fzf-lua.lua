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
    { '<leader>fw', '<cmd>FzfLua colorschemes<CR>' },
  },
  init = function()
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function(...)
      require('lazy').load({ plugins = { 'fzf-lua' } })
      return vim.ui.select(...)
    end
  end,
  config = function()
    local fzf_lua = require('fzf-lua')
    fzf_lua.setup({
      winopts = {
        border = 'single',
        preview = {
          border = 'single',
        },
        backdrop = 100,
        on_create = function()
          vim.keymap.set('t', '<C-e>', '<down>', { silent = true, buffer = true })
          vim.keymap.set('t', '<C-u>', '<up>', { silent = true, buffer = true })
        end,
      },
      fzf_colors = true,
    })
    fzf_lua.register_ui_select()
  end
}
