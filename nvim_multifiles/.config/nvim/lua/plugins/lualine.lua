return {
  'nvim-lualine/lualine.nvim',
  event = { 'User FileOpened', 'BufAdd' },
  dependencies = { 'echasnovski/mini.icons' },
  config = function()
    local simple_mode = require('utils.simple_mode')
    local get_hl = require('utils.get_hl')

    local get_date = function()
      return os.date('%D %R')
    end

    local lsp_clients = function()
      local bufnr = vim.api.nvim_get_current_buf()

      local clients = vim.lsp.get_clients({ buffer = bufnr })
      if next(clients) == nil then
        return ''
      end

      local c = {}
      for _, client in pairs(clients) do
        table.insert(c, client.name)
      end
      return ' ' .. table.concat(c, ', ')
    end

    require('lualine').setup({
      options = {
        component_separators = '',
        section_separators = { left = '', right = '' },
        disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'ministarter' } },
        globalstatus = true,
      },
      sections = {
        lualine_a = { simple_mode },
        lualine_b = { 'filename', 'searchcount', 'selectioncount' },
        lualine_c = {
          'branch',
          'diff',
          'filesize',
          'filetype',
          'encoding',
          {
            'diagnostics',
            symbols = {
              error = 'E',
              warn = 'W',
              hint = 'H',
              info = 'I',
            },
          },
        },

        lualine_x = {
          -- { 'filename', path = 3 },
          -- stylua: ignore
          {
            function() return require('noice').api.status.command.get() end,
            cond = function() return package.loaded['noice'] and require('noice').api.status.command.has() end,
            color = function()
              return { fg = get_hl('Statement') }
            end
          },

          -- stylua: ignore
          {
            function() return require('noice').api.status.mode.get() end,
            cond = function() return package.loaded['noice'] and require('noice').api.status.mode.has() end,
            color = function()
              return { fg = get_hl('Constant') }
            end
          },
          lsp_clients,
          'tabnine',
          'hostname',
          'fileformat',
        },
        lualine_y = {
          { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
          { 'location', padding = { left = 0, right = 1 } },
        },
        lualine_z = { get_date },
      },
    })
  end,
}
