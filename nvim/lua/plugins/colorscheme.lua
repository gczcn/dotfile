local set_hl = vim.api.nvim_set_hl
local get_hl = vim.api.nvim_get_hl

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    if vim.g.colors_name == 'gruvbox' then
      set_hl(0, 'NoiceCmdlinePopupBorder', get_hl(0, { name = 'Normal' }))
      set_hl(0, 'NoiceCmdlinePopupTitle', get_hl(0, { name = 'Normal' }))
      set_hl(0, 'NoiceCmdlineIcon', get_hl(0, { name = 'GruvboxOrange' }))
      set_hl(0, 'TelescopePromptBorder', get_hl(0, { name = 'GruvboxOrange' }))
      set_hl(0, 'GitSignsCurrentLineBlame', get_hl(0, { name = 'Comment' }))
    end
  end
})
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
