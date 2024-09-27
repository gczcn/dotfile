return {
  'nvim-lualine/lualine.nvim',
  event = { 'User FileOpened', 'BufAdd' },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local simple_mode = require('utils.simple_mode')
    local get_hl = require('utils.get_hl')

    local get_date = function()
      return os.date('%D %R:%S')
    end

    require('lualine').setup({
      options = {
        component_separators = '',
        section_separators = { left = '', right = '' },
        disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'ministarter' } },
        globalstatus = true,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'filename', 'searchcount', 'selectioncount' },
        lualine_c = { 'branch', 'diff', 'filesize', 'filetype', 'encoding', {
          'diagnostics',
          symbols = {
            error = 'E',
            warn = 'W',
            hint = 'H',
            info = 'I',
          },
        },
        },

        lualine_x = { { 'filename', path = 3 }, 'tabnine', 'hostname', 'fileformat' },
        lualine_y = {
          { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
          { 'location', padding = { left = 0, right = 1 } },
        },
        lualine_z = { get_date },
      },
      -- inactive_sections = {
      --   lualine_a = {},
      --   lualine_b = {},
      --   lualine_c = { 'filename', 'branch', 'diff', 'filesize', 'filetype', 'encoding' },
      --   lualine_x = { 'progress', 'location' },
      --   lualine_y = {},
      --   lualine_z = {},
      -- },
      tabline = {
        lualine_a = { { 'buffers', mode = 2, use_mode_colors = true } },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { { 'tabs', mode = 2, use_mode_colors = true } },
      },
    })

    -- Set keymaps
    local opts = { noremap = true, silent = true }

    -- Buffers
    vim.keymap.set('n', '<leader>0', '<cmd>LualineBuffersJump $<CR>', opts)
    for i = 1, 9 do
      vim.keymap.set('n', ('<leader>%s'):format(i), ('<cmd>LualineBuffersJump %s<CR>'):format(i), opts)
    end

    -- Tabs
    vim.keymap.set('n', '<TAB>', '<cmd>tabnext<CR>', opts)
    vim.keymap.set('n', '<S-TAB>', '<cmd>tabprev<CR>', opts)
  end
}
