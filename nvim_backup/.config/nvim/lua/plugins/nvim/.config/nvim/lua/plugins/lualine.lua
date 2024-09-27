return {
  'nvim-lualine/lualine.nvim',
  event = { 'User FileOpened', 'BufAdd' },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local simple_mode = require('utils.simple_mode')

    local get_date = function()
      return os.date('%D %R:%S')
    end

    require('lualine').setup({
      options = {
        component_separators = '',
        section_separators = { left = '', right = '' },
        disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'ministarter' } },
      },
      sections = {
        lualine_a = { 'mode' },
      },
    })
  end
}
