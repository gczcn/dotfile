return {
  { 'nvim-tree/nvim-web-devicons', lazy = true, dependencies = { 'rachartier/tiny-devicons-auto-colors.nvim' } },
  {
    'rachartier/tiny-devicons-auto-colors.nvim',
    lazy = true,
    config = function()
      local theme_colors = require('gruvbox').palette
      require('tiny-devicons-auto-colors').setup({
        colors = theme_colors
      })
    end
  }
}
