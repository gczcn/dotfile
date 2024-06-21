return {
  {
    'nvim-lualine/lualine.nvim',
    event = { 'User FileOpened', 'BufAdd' },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local Utils = require('utils')

      local get_date = function()
        return os.date('%D %R:%S')
      end

      local lsp_clients = function()
        local clients = vim.lsp.get_clients()
        local clients_list = {}
        for _, client in pairs(clients) do
          table.insert(clients_list, client.name)
        end
        return Utils.dump(clients_list)
      end

      require('lualine').setup({
        options = {
          component_separators = '',
          section_separators = { left = '', right = '' },
          disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'starter' } },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'filename', 'searchcount', 'selectioncount' },
          lualine_c = { 'branch', 'diff', 'filesize', 'filetype', 'encoding', {
            'diagnostics',
            symbols = {
              error = 'E ',
              warn = 'W ',
              hint = 'H ',
              info = 'I ',
            },
          },
          },

          lualine_x = {
            { 'filename', path = 3 },
            -- stylua: ignore
            {
              function() return require('noice').api.status.command.get() end,
              cond = function() return package.loaded['noice'] and require('noice').api.status.command.has() end,
              color = function()
                return { fg = Utils.get_hl('Statement', 'fg') }
              end
            },

            -- stylua: ignore
            {
              function() return require('noice').api.status.mode.get() end,
              cond = function() return package.loaded['noice'] and require('noice').api.status.mode.has() end,
              color = function()
                return { fg = Utils.get_hl('Constant', 'fg') }
              end
            },

            -- stylua: ignore
            {
              function() return '  ' .. require('dap').status() end,
              cond = function () return package.loaded['dap'] and require('dap').status() ~= '' end,
              color = function()
                return { fg = Utils.get_hl('Debug', 'fg') }
              end
            },

            -- stylua: ignore
            {
              require('lazy.status').updates,
              cond = require('lazy.status').has_updates,
              color = { fg = Utils.get_hl('Special', 'fg') },
            },
            lsp_clients, 'tabnine', 'hostname', 'fileformat' },
          lualine_y = {
            { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
            { 'location', padding = { left = 0, right = 1 } },
          },
          lualine_z = { get_date },
        },

        inactive_sections = {
          lualine_a = { 'filename' },
          lualine_b = {},
          lualine_c = { 'branch', 'diff', 'searchcount', 'selectioncount', 'filesize', 'filetype', 'encoding', {
            'diagnostics',
            symbols = {
              error = 'E ',
              warn = 'W ',
              hint = 'H ',
              info = 'I ',
            },
          } },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {
            { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
            { 'location', padding = { left = 0, right = 1 } },
          }
        },
      })
    end
  }
}
