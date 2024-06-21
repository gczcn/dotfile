return {
  {
    'willothy/nvim-cokeline',
    event = { 'User FileOpened', 'BufAdd' },
    dependencies = {
      'nvim-lualine/lualine.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'stevearc/resession.nvim',
    },
    config = function()
      local Utils = require('utils')

      local is_picking_focus = require('cokeline/mappings').is_picking_focus
      local is_picking_close = require('cokeline/mappings').is_picking_close

      local get_colors = function(a, b)
        if next(vim.api.nvim_get_hl(0, {name = 'lualine_' .. a .. '_' .. b})) ~= nil then
          return vim.api.nvim_get_hl(0, {name = 'lualine_' .. a .. '_' .. b})
        end
        return vim.api.nvim_get_hl(0, {name = 'lualine_' .. a .. '_normal'})
      end

      local mode_list = {
        n = 'normal',
        v = 'visual',
        V = 'visual',
        i = 'insert',
        c = 'command',
        R = 'replace',
      }

      local get_mode = function()
        if mode_list[vim.api.nvim_get_mode().mode] then
          return mode_list[vim.api.nvim_get_mode().mode]
        end
        return 'normal'
      end

      local colors = function()
        return {
          error = Utils.get_hl('DiagnosticError', 'fg'),
          warn = Utils.get_hl('DiagnosticWarn', 'fg'),
          hint = Utils.get_hl('DiagnosticHint', 'fg'),
          info = Utils.get_hl('DiagnosticInfo', 'fg'),
        }
      end

      local diagnostics_colors_fg = function(buffer, type)
        if buffer.is_focused then
          return get_colors('a', get_mode())['fg']
        end
        return colors()[type]
      end

      local diagnostics_colors_bg = function(buffer, type)
        if buffer.is_focused then
          return colors()[type]
        end
        return get_colors('b', get_mode())['bg']
      end

      -- Get buffer name
      local function get_path_parts(path)
        local dirs = {}
        for dir in string.gmatch(path, '([^/]+)') do
          table.insert(dirs, dir)
        end

        local filename = dirs[#dirs]
        if filename ~= nil and string.sub(filename, 1, 1) == '+' then
          local ext = filename:match('^.+(%..+)$')
          local last_dir = dirs[#dirs - 1]
          if last_dir == '[id]' and path:match('api') and filename == '+server.ts' then
            local id_index = 0
            for i, dir in ipairs(dirs) do
              if dir == '[id]' then
                id_index = i
              end
            end
            local new_dir = dirs[id_index - 1]
            return new_dir .. '/[id]/' .. filename
          elseif last_dir == '[id]' then
            local id_index = 0
            for i, dir in ipairs(dirs) do
              if dir == '[id]' then
                id_index = i
              end
            end
            local new_dir = dirs[id_index - 1]
            return new_dir .. '/[id]/' .. filename
          elseif path:match('api') then
            local api_index = 0
            for i, dir in ipairs(dirs) do
              if dir == 'api' then
                api_index = i
              end
            end
            local api_next_dir = dirs[api_index + 1]
            return 'api/' .. api_next_dir .. '/' .. filename
          elseif ext == nil then
            local dir = dirs[#dirs - 1]
            return dir .. '/' .. filename
          else
            local dir = dirs[#dirs - 1]
            return dir .. '/' .. filename
          end
        end
      end

      -- Mode color switch
      vim.api.nvim_create_autocmd({ 'ModeChanged', 'ColorScheme' }, {
        pattern = '*',
        callback = function()
          vim.api.nvim_set_hl(0, 'TabLineFill', get_colors('c', get_mode()))
        end
      })

      -- set keymaps
      local opts = { silent = true }

      vim.keymap.set('n', '<S-TAB>', '<Plug>(cokeline-focus-prev)', opts)
      vim.keymap.set('n', '<TAB>', '<Plug>(cokeline-focus-next)', opts)
      vim.keymap.set('n', '<M-N>', '<Plug>(cokeline-switch-prev)', opts)
      vim.keymap.set('n', '<M-I>', '<Plug>(cokeline-switch-next)', opts)

      vim.keymap.set('n', '<leader>0', function()
        vim.ui.input({ prompt = 'cokeline focus: Buffer index' }, function(index)
          if index ~= nil then
            vim.cmd(('call feedkeys("\\<Plug>\\(cokeline-focus-%s)")'):format(index))
          end
        end)
      end, opts)

      vim.keymap.set('n', '<leader>d0', function()
        vim.ui.input({ prompt = 'cokeline switch: Buffer index' }, function(index)
          if index ~= nil then
            vim.cmd(('call feedkeys("\\<Plug>\\(cokeline-switch-%s)")'):format(index))
          end
        end)
      end, opts)

      for i = 1, 9 do
        vim.keymap.set('n', ('<leader>%s'):format(i), ('<Plug>(cokeline-focus-%s)'):format(i), { silent = true })
        vim.keymap.set('n', ('<leader>d%s'):format(i), ('<Plug>(cokeline-switch-%s)'):format(i), { silent = true })
      end

      require('cokeline').setup({
        default_hl = {
          fg = function(buffer)
            if buffer.is_focused then
              return get_colors('a', get_mode())['fg']
            end
            return get_colors('b', get_mode())['fg']
          end,
          bg = function(buffer)
            if buffer.is_focused then
              return get_colors('a', get_mode())['bg']
            end
            return get_colors('b', get_mode())['bg']
          end,
          bold = function(buffer)
            return buffer.is_focused or buffer.is_hovered
          end,
        },
        components = {
          {
            text = function(buffer)
              return ' ' .. buffer.index .. ' '
            end,
          },
          {
            text = function(buffer)
              if is_picking_focus() or is_picking_close() then
                return buffer.pick_letter
              end
              return buffer.devicon.icon
            end,
            style = function(_)
              return (is_picking_focus() or is_picking_close()) and 'italic,bold' or nil
            end,
          },
          {
            text = function(buffer)
              if get_path_parts(buffer.path) ~= nil then
                return get_path_parts(buffer.path) .. ' '
              end
              return buffer.unique_prefix .. buffer.filename .. ' '
            end,
          },
          {
            text = function(buffer)
              return buffer.is_modified and '* ' or ''
            end,
          },
          {
            text = function(buffer)
              if buffer.is_focused then
                return buffer.diagnostics.errors ~= 0 and ' ' .. buffer.diagnostics.errors .. ' ' or ''
              end
              return buffer.diagnostics.errors ~= 0 and buffer.diagnostics.errors .. ' ' or ''
            end,
            fg = function(buffer)
              return diagnostics_colors_fg(buffer, 'error')
            end,
            bg = function(buffer)
              return diagnostics_colors_bg(buffer, 'error')
            end,
          },
          {
            text = function(buffer)
              if buffer.is_focused then
                return buffer.diagnostics.warnings ~= 0 and ' ' .. buffer.diagnostics.warnings .. ' ' or ''
              end
              return buffer.diagnostics.warnings ~= 0 and buffer.diagnostics.warnings .. ' ' or ''
            end,
            fg = function(buffer)
              return diagnostics_colors_fg(buffer, 'warn')
            end,
            bg = function(buffer)
              return diagnostics_colors_bg(buffer, 'warn')
            end,
          },
          {
            text = function(buffer)
              if buffer.is_focused then
                return buffer.diagnostics.hints ~= 0 and ' ' .. buffer.diagnostics.hints .. ' ' or ''
              end
              return buffer.diagnostics.hints ~= 0 and buffer.diagnostics.hints .. ' ' or ''
            end,
            fg = function(buffer)
              return diagnostics_colors_fg(buffer, 'hint')
            end,
            bg = function(buffer)
              return diagnostics_colors_bg(buffer, 'hint')
            end,
          },
          {
            text = function(buffer)
              if buffer.is_focused then
                return buffer.diagnostics.infos ~= 0 and ' ' .. buffer.diagnostics.infos .. ' ' or ''
              end
              return buffer.diagnostics.infos ~= 0 and buffer.diagnostics.infos .. ' ' or ''
            end,
            fg = function(buffer)
              return diagnostics_colors_fg(buffer, 'info')
            end,
            bg = function(buffer)
              return diagnostics_colors_bg(buffer, 'info')
            end,
          },
        },
      })
      vim.api.nvim_set_hl(0, 'TabLineFill', get_colors('c', get_mode()))
    end
  }
}
