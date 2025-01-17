return {
  'nvim-lualine/lualine.nvim',
  event = { 'User FileOpened', 'BufAdd' },
  -- dependencies = { 'nvim-tree/nvim-web-devicons' },
  dependencies = { 'echasnovski/mini.icons' },
  config = function()
    -- columns = {
    --   'icon',
    --   'permissions',
    --   'size',
    --   -- 'mtime',
    -- },
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
      -- inactive_sections = {
      --   lualine_a = {},
      --   lualine_b = {},
      --   lualine_c = { 'filename', 'branch', 'diff', 'filesize', 'filetype', 'encoding' },
      --   lualine_x = { 'progress', 'location' },
      --   lualine_y = {},
      --   lualine_z = {},
      -- },
      -- tabline = {
      --   lualine_a = { {
      --     'buffers',
      --     mode = 2,
      --     use_mode_colors = true,
      --     filetype_names = {
      --       oil = 'Oil',
      --     },
      --     symbols = {
      --       modified = ' *',      -- Text to show when the buffer is modified
      --       alternate_file = '#', -- Text to show to identify the alternate file
      --       directory =  '',     -- Text to show when the buffer is a directory
      --     },
      --   } },
      --   lualine_b = {},
      --   lualine_c = {},
      --   lualine_x = {},
      --   lualine_y = {},
      --   lualine_z = { { 'tabs', mode = 2, use_mode_colors = true } },
      -- },
    })
  end,
}
