return {
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      require('gruvbox').setup({
        ---@diagnostic disable-next-line: missing-fields
        italic = {
          strings = false,
        },
        overrides = {
          Visual = { bold = true }
        },
      })
      vim.cmd.colorscheme('gruvbox')
    end
  }
}
