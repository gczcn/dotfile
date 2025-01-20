return {
  'stevearc/conform.nvim',
  cmd = { 'ConformInfo' },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      '<leader>cf',
      function()
        require('conform').format({ async = true })
      end,
      mode = '',
      desc = 'Format buffer',
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'isort', 'black' },
      javascript = { { 'prettierd', 'prettier' } },
      c = { 'clang-format' },
    },
    formatters = {
      shfmt = {
        prepend_args = { '-i', '2' },
      },
    },
  },
}
