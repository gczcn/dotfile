-- test: #000000, #ffffff, #ff0000, #00ff00, #0000ff

return {
  {
    'NvChad/nvim-colorizer.lua',
    event = 'VeryLazy',
    config = function()
      require('colorizer').setup({
        user_default_options = {
          always_update = true,
        },
      })
      vim.cmd.ColorizerReloadAllBuffers()
      vim.cmd.ColorizerToggle()
    end,
  }
}
