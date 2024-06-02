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
        overrides = {
          Visual = { bold = true },
        },
      })
      vim.cmd.colorscheme('gruvbox')
    end
  },

  -- Alternative color scheme, will be loaded when pressing '<leader>tt'
  { 'catppuccin/nvim', name = 'catppuccin', event = 'User LoadColors' },
  { 'EdenEast/nightfox.nvim', event = 'User LoadColors' },
  { 'maxmx03/solarized.nvim', event = 'User LoadColors' },
  { 'sainnhe/everforest', event = 'User LoadColors' },
  { 'projekt0n/github-nvim-theme', event = 'User LoadColors' },
}
