return {
  'willothy/nvim-cokeline',
  enabled = true,
  event = { 'User FileOpened', 'BufAdd' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'echasnovski/mini.icons',
    'stevearc/resession.nvim',
  },
  config = function()
    local is_picking_focus = require('cokeline.mappings').is_picking_focus
    local is_picking_close = require('cokeline.mappings').is_picking_close

    local hl = {
      dark = {
        focused = {
          normal = { bg = '#a89984', fg = '#282828', bold = true },
          insert = { bg = '#83a598', fg = '#282828', bold = true },
          command = { bg = '#b8bb26', fg = '#282828', bold = true },
          visual = { bg = '#fe8019', fg = '#282828', bold = true },
          select = { bg = '#fe8019', fg = '#282828', bold = true },
          replace = { bg = '#fb4934', fg = '#282828', bold = true },
          term = { bg = '#a89984', fg = '#282828', bold = true },
          normal_num = { bg = '#928374', fg = '#282828', bold = true },
          insert_num = { bg = '#458588', fg = '#282828', bold = true },
          command_num = { bg = '#98971a', fg = '#282828', bold = true },
          visual_num = { bg = '#d65d0e', fg = '#282828', bold = true },
          select_num = { bg = '#d65d0e', fg = '#282828', bold = true },
          replace_num = { bg = '#cc241d', fg = '#282828', bold = true },
          term_num = { bg = '#928374', fg = '#282828', bold = true },
          unique_prefix_fg = '#504945',
          diagnostic_error = { bg = '#fb4934', fg = '#282828', bold = true },
          diagnostic_warn = { bg = '#fabd2f', fg = '#282828', bold = true },
          diagnostic_info = { bg = '#83a598', fg = '#282828', bold = true },
          diagnostic_hint = { bg = '#8ec07c', fg = '#282828', bold = true },
        },
        not_focused = {
          normal = { bg = '#504945', fg = '#ebdbb2' },
          insert = { bg = '#504945', fg = '#ebdbb2' },
          command = { bg = '#504945', fg = '#ebdbb2' },
          visual = { bg = '#504945', fg = '#ebdbb2' },
          select = { bg = '#504945', fg = '#ebdbb2' },
          replace = { bg = '#504945', fg = '#ebdbb2' },
          term = { bg = '#504945', fg = '#ebdbb2' },
          normal_num = { bg = '#665c54', fg = '#ebdbb2' },
          insert_num = { bg = '#665c54', fg = '#ebdbb2' },
          command_num = { bg = '#665c54', fg = '#ebdbb2' },
          visual_num = { bg = '#665c54', fg = '#ebdbb2' },
          select_num = { bg = '#665c54', fg = '#ebdbb2' },
          replace_num = { bg = '#665c54', fg = '#ebdbb2' },
          term_num = { bg = '#665c54', fg = '#ebdbb2' },
          unique_prefix_fg = '#bdae93',
          diagnostic_error = { bg = '#504945', fg = '#fb4934' },
          diagnostic_warn = { bg = '#504945', fg = '#fabd2f' },
          diagnostic_info = { bg = '#504945', fg = '#83a598' },
          diagnostic_hint = { bg = '#504945', fg = '#8ec07c' },
        },
        tablinefill = {
          normal = { bg = '#3c3836', fg = '#a89984' },
          insert = { bg = '#504945', fg = '#ebdbb2' },
          command = { bg = '#7c6f64', fg = '#282828' },
          visual = { bg = '#7c6f64', fg = '#282828' },
          select = { bg = '#7c6f64', fg = '#282828' },
          replace = { bg = '#282828', fg = '#ebdbb2' },
          term = { bg = '#3c3836', fg = '#a89984' },
        },
        quit = { bg = '#fb4934', fg = '#282828', bold = true }
      },
      light = {
        focused = {
          normal = { bg = '#7c6f64', fg = '#f9f5d7', bold = true },
          insert = { bg = '#076678', fg = '#f9f5d7', bold = true },
          command = { bg = '#79740e', fg = '#f9f5d7', bold = true },
          visual = { bg = '#af3a03', fg = '#f9f5d7', bold = true },
          select = { bg = '#af3a03', fg = '#f9f5d7', bold = true },
          replace = { bg = '#9d0006', fg = '#f9f5d7', bold = true },
          term = { bg = '#7c6f64', fg = '#f9f5d7', bold = true },
          normal_num = { bg = '#928374', fg = '#f9f5d7', bold = true },
          insert_num = { bg = '#458588', fg = '#f9f5d7', bold = true },
          command_num = { bg = '#98971a', fg = '#f9f5d7', bold = true },
          visual_num = { bg = '#d65d0e', fg = '#f9f5d7', bold = true },
          select_num = { bg = '#d65d0e', fg = '#f9f5d7', bold = true },
          replace_num = { bg = '#cc241d', fg = '#f9f5d7', bold = true },
          term_num = { bg = '#928374', fg = '#f9f5d7', bold = true },
          unique_prefix_fg = '#d5c4a1',
          diagnostic_error = { bg = '#9d0006', fg = '#f9f5d7', bold = true },
          diagnostic_warn = { bg = '#b57614', fg = '#f9f5d7', bold = true },
          diagnostic_info = { bg = '#076678', fg = '#f9f5d7', bold = true },
          diagnostic_hint = { bg = '#427b58', fg = '#f9f5d7', bold = true },
        },
        not_focused = {
          normal = { bg = '#d5c4a1', fg = '#7c6f64' },
          insert = { bg = '#d5c4a1', fg = '#7c6f64' },
          command = { bg = '#d5c4a1', fg = '#7c6f64' },
          visual = { bg = '#d5c4a1', fg = '#7c6f64' },
          select = { bg = '#d5c4a1', fg = '#7c6f64' },
          replace = { bg = '#d5c4a1', fg = '#7c6f64' },
          term = { bg = '#d5c4a1', fg = '#7c6f64' },
          normal_num = { bg = '#bdae93', fg = '#7c6f64' },
          insert_num = { bg = '#bdae93', fg = '#7c6f64' },
          command_num = { bg = '#bdae93', fg = '#7c6f64' },
          visual_num = { bg = '#bdae93', fg = '#7c6f64' },
          select_num = { bg = '#bdae93', fg = '#7c6f64' },
          replace_num = { bg = '#bdae93', fg = '#7c6f64' },
          term_num = { bg = '#bdae93', fg = '#7c6f64' },
          unique_prefix_fg = '#bdae93',
          diagnostic_error = { bg = '#d5c4a1', fg = '#9d0006' },
          diagnostic_warn = { bg = '#d5c4a1', fg = '#b57614' },
          diagnostic_info = { bg = '#d5c4a1', fg = '#076678' },
          diagnostic_hint = { bg = '#d5c4a1', fg = '#427b58' },
        },
        tablinefill = {
          normal = { bg = '#ebdbb2', fg = '#7c6f64' },
          insert = { bg = '#d5c4a1', fg = '#3c3835' },
          command = { bg = '#ebdbb2', fg = '#7c6f64' },
          visual = { bg = '#7c6f64', fg = '#f9f5d7' },
          select = { bg = '#7c6f64', fg = '#f9f5d7' },
          replace = { bg = '#d5c4a1', fg = '#3c3836' },
          term = { bg = '#ebdbb2', fg = '#7c6f64' },
        },
        quit = { bg = '#9d0006', fg = '#f9f5d7', bold = true }
      },
    }

    local get_mode = function()
      local mode = vim.api.nvim_get_mode().mode or 'n'
      local mode_first_char = string.sub(mode, 1, 1)
      if mode_first_char == 'n' then return 'normal'
      elseif string.lower(mode_first_char) == 'v' or mode == '\22' or mode == '\22s' then return 'visual'
      elseif string.lower(mode_first_char) == 's' or mode == '\19' then return 'select'
      elseif mode_first_char == 'i' then return 'insert'
      elseif mode_first_char == 'R' then return 'replace'
      elseif mode_first_char == 'c' then return 'command'
      elseif mode_first_char == 't' then return 'term'
      else return 'normal'
      end
    end

    local get_hl = function()
      return hl[(vim.o.background == 'dark' or vim.o.background == 'light') and vim.o.background or 'dark']
    end

    vim.api.nvim_create_autocmd({ 'ModeChanged', 'ColorScheme' }, {
      pattern = '*',
      callback = function()
        vim.api.nvim_set_hl(0, 'TabLineFill', get_hl()['tablinefill'][get_mode()])
      end
    })

    -- Set keymaps
    local opts = { noremap = true, silent = true }

    -- Buffers
    local keyboard = { 'o', 'a', 'r', 's', 't', 'd', 'h', 'n', 'e', 'i' }
    vim.keymap.set('n', ']0', '<cmd>LualineBuffersJump $<CR>', opts)
    for i = 1, 9 do
      vim.keymap.set('n', (']%s'):format(keyboard[i + 1]), ('<Plug>(cokeline-focus-%s)'):format(i), opts)
    end
    vim.keymap.set('n', ']a', function()
      vim.ui.input({ prompt = 'Buffer Index:' }, function(index)
        if index then
          vim.cmd(('call feedkeys("\\<Plug>\\(cokeline-focus-%s)")'):format(index))
        end
      end)
    end)

    -- Tabs
    vim.keymap.set('n', '<TAB>', '<cmd>tabnext<CR>', opts)
    vim.keymap.set('n', '<S-TAB>', '<cmd>tabprev<CR>', opts)

    require('cokeline').setup({
      default_hl = {
        fg = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode()]['fg'] end,
        bg = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode()]['bg'] end,
        bold = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode()]['bold'] end,
        italic = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode()]['italic'] end,
        underline = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode()]['underline'] end,
        undercurl = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode()]['undercurl'] end,
        strikethrough = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode()]['strikethrough'] end,
      },
      components = {
        {
          text = function(buffer) return ' ' .. buffer.index .. ' ' end,
          bg = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode() .. '_num']['bg'] end,
          fg = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode() .. '_num']['fg'] end,
          bold = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode() .. '_num']['bold'] end,
          italic = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode() .. '_num']['italic'] end,
          underline = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode() .. '_num']['underline'] end,
          strikethrough = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused'][get_mode() .. '_num']['strikethrough'] end,
        },
        {
          text = function(buffer)
            if is_picking_focus() or is_picking_close() then
              return ' ' .. buffer.pick_letter
            end
            return ' ' .. buffer.devicon.icon
          end,
          style = function(_)
            return (is_picking_focus() or is_picking_close()) and 'italic,bold' or nil
          end,
        },
        {
          text = function(buffer)
            return buffer.unique_prefix
          end,
          fg = function(buffer)
            return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['unique_prefix_fg']
          end,
        },
        {
          text = function(buffer)
            return buffer.filename .. ' '
          end,
        },
        {
          text = function(buffer)
            return buffer.is_modified and '* ' or ''
          end,
        },
        {
          text = function(buffer)
            return buffer.diagnostics.errors ~= 0 and ((buffer.is_focused and ' ' or '') .. buffer.diagnostics.errors .. ' ') or ''
          end,
          bg = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_error']['bg'] end,
          fg = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_error']['fg'] end,
          bold = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_error']['bold'] end,
          italic = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_error']['italic'] end,
          underline = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_error']['underline'] end,
          undercurl = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_error']['undercurl'] end,
          strikethrough = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_error']['strikethrough'] end,
        },
        {
          text = function(buffer)
            return buffer.diagnostics.warnings ~= 0 and ((buffer.is_focused and ' ' or '') .. buffer.diagnostics.warnings .. ' ') or ''
          end,
          bg = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_warn']['bg'] end,
          fg = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_warn']['fg'] end,
          bold = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_warn']['bold'] end,
          italic = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_warn']['italic'] end,
          underline = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_warn']['underline'] end,
          undercurl = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_warn']['undercurl'] end,
          strikethrough = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_warn']['strikethrough'] end,
        },
        {
          text = function(buffer)
            return buffer.diagnostics.hints ~= 0 and ((buffer.is_focused and ' ' or '') .. buffer.diagnostics.hints .. ' ') or ''
          end,
          bg = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_hint']['bg'] end,
          fg = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_hint']['fg'] end,
          bold = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_hint']['bold'] end,
          italic = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_hint']['italic'] end,
          underline = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_hint']['underline'] end,
          undercurl = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_hint']['undercurl'] end,
          strikethrough = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_hint']['strikethrough'] end,
        },
        {
          text = function(buffer)
            return buffer.diagnostics.infos ~= 0 and ((buffer.is_focused and ' ' or '') .. buffer.diagnostics.infos .. ' ') or ''
          end,
          bg = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_info']['bg'] end,
          fg = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_info']['fg'] end,
          bold = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_info']['bold'] end,
          italic = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_info']['italic'] end,
          underline = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_info']['underline'] end,
          undercurl = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_info']['undercurl'] end,
          strikethrough = function(buffer) return get_hl()[buffer.is_focused and 'focused' or 'not_focused']['diagnostic_info']['strikethrough'] end,
        },
      },
      tabs = {
        placement = 'right',
      },
      rhs = {
        {
          text = ' X ',
          bg = function() return get_hl()['quit']['bg'] end,
          fg = function() return get_hl()['quit']['fg'] end,
          bold = function() return get_hl()['quit']['bold'] end,
          italic = function() return get_hl()['quit']['italic'] end,
          underline = function() return get_hl()['quit']['underline'] end,
          undercurl = function() return get_hl()['quit']['undercurl'] end,
          strikethrough = function() return get_hl()['quit']['strikethrough'] end,
          on_click = function()
            vim.ui.input({ prompt = 'Quit Neovim? Y/n' }, function(input)
              if input == '' or string.lower(input) == 'y' then
                vim.cmd.qa()
              end
            end)
          end
        }
      },
    })
  end
}
