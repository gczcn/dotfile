return {
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      require('gruvbox').setup({
        italic = {
          strings = false,
        },
      })
      vim.cmd.colorscheme('gruvbox')
    end
  },

  { 'EdenEast/nightfox.nvim', lazy = true },
  { 'maxmx03/solarized.nvim', lazy = true },
}
