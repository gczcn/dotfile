return {
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true,
    dependencies = {
      'rachartier/tiny-devicons-auto-colors.nvim',
    },
  },
  {
    'rachartier/tiny-devicons-auto-colors.nvim',
    enabled = true,
    lazy = true,
    config = function()
      local palette = function()
        if vim.g.colors_name == 'gruvbox' then
          return require('gruvbox').palette
        end
        return nil
      end
      palette = palette()

      require('tiny-devicons-auto-colors').setup({ colors = palette })
    end,
  }
}
