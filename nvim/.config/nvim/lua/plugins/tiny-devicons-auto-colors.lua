if true then return {} end

return {
  { 'nvim-tree/nvim-web-devicons', lazy = true, dependencies = { 'rachartier/tiny-devicons-auto-colors.nvim' } },
  {
    'rachartier/tiny-devicons-auto-colors.nvim',
    lazy = true,
    config = function()
      local palette = require('catppuccin.palettes').get_palette('mocha')

      require('tiny-devicons-auto-colors').setup({
        colors = palette
      })
    end
  }
}
