return {
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    enabled = true,
    config = function()
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = function()
          if vim.g.colors_name == 'gruvbox' then
            local p = require('gruvbox').palette
            local set_hl = vim.api.nvim_set_hl
            local colors = vim.o.background == 'dark' and {
              bg0 = p.dark0,
              bg1 = p.dark1,
              bg2 = p.dark2,
              bg3 = p.dark3,
              bg4 = p.dark4,
              fg0 = p.light0,
              fg1 = p.light1,
              fg2 = p.light2,
              fg3 = p.light3,
              fg4 = p.light4,
              red = p.bright_red,
              green = p.bright_green,
              yellow = p.bright_yellow,
              blue = p.bright_blue,
              purple = p.bright_purple,
              aqua = p.bright_aqua,
              orange = p.bright_orange,
              neutral_red = p.neutral_red,
              neutral_green = p.neutral_green,
              neutral_yellow = p.neutral_yellow,
              neutral_blue = p.neutral_blue,
              neutral_purple = p.neutral_purple,
              neutral_aqua = p.neutral_aqua,
              dark_red = p.dark_red,
              dark_green = p.dark_green,
              dark_aqua = p.dark_aqua,
              gray = p.gray,
            } or {
              bg0 = p.light0,
              bg1 = p.light1,
              bg2 = p.light2,
              bg3 = p.light3,
              bg4 = p.light4,
              fg0 = p.dark0,
              fg1 = p.dark1,
              fg2 = p.dark2,
              fg3 = p.dark3,
              fg4 = p.dark4,
              red = p.faded_red,
              green = p.faded_green,
              yellow = p.faded_yellow,
              blue = p.faded_blue,
              purple = p.faded_purple,
              aqua = p.faded_aqua,
              orange = p.faded_orange,
              neutral_red = p.neutral_red,
              neutral_green = p.neutral_green,
              neutral_yellow = p.neutral_yellow,
              neutral_blue = p.neutral_blue,
              neutral_purple = p.neutral_purple,
              neutral_aqua = p.neutral_aqua,
              dark_red = p.light_red,
              dark_green = p.light_green,
              dark_aqua = p.light_aqua,
              gray = p.gray,
            }
            set_hl(0, 'DiagnosticNumHlError', { fg = colors.red, bold = true })
            set_hl(0, 'DiagnosticNumHlWarn', { fg = colors.yellow, bold = true })
            set_hl(0, 'DiagnosticNumHlHint', { fg = colors.aqua, bold = true })
            set_hl(0, 'DiagnosticNumHlInfo', { fg = colors.blue, bold = true })

            set_hl(0, 'NoiceCmdlineIcon', { fg = colors.orange })
            set_hl(0, 'NoiceCmdlineIconLua', { fg = colors.blue })
            set_hl(0, 'NoiceCmdlineIconHelp', { fg = colors.red })

            set_hl(0, 'FzfLuaHeaderText', { fg = colors.red })
            set_hl(0, 'FzfLuaHeaderBind', { fg = colors.orange })

            set_hl(0, 'FlashLabel', { bg = colors.red, fg = colors.bg0 })

            set_hl(0, 'BlinkCmpKindClass', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindColor', { bg = colors.purple, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindConstant', { bg = colors.orange, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindConstructor', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindEnum', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindEnumMember', { bg = colors.aqua, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindEvent', { bg = colors.purple, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindField', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindFile', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindFolder', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindFunction', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindInterface', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindKeyword', { bg = colors.purple, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindMethod', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindModule', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindOperator', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindProperty', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindReference', { bg = colors.purple, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindSnippet', { bg = colors.green, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindStruct', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindText', { bg = colors.orange, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindTypeParameter', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindUnit', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindValue', { bg = colors.orange, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindVariable', { bg = colors.orange, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindCopilot', { bg = colors.gray, fg = colors.bg1 })
          end
        end
      })
      local palette = require('gruvbox').palette
      require('gruvbox').setup({
        italic = {
          strings = false,
          comments = false,
        },
        overrides = {
          -- noice.nvim
          NoiceCmdlinePopupBorder = { link = 'Normal' },
          NoiceCmdlinePopupTitle = { link = 'Normal' },

          -- Lualine
          -- check https://github.com/nvim-lualine/lualine.nvim/issues/1312 for more information
          StatusLine = { reverse = false },
          StatusLineNC = { reverse = false },

          -- nvim-scrollbar
          -- lua/plugins/nvim-scrollbar.lua change_highlight()

          -- vim-illuminate
          IlluminatedWordText = { underline = true },
          IlluminatedWordRead = { underline = true },
          IlluminatedWordWrite = { underline = true },

          -- gitsigns.nvim
          GitSignsCurrentLineBlame = { fg = palette.dark4 },

          -- blink.cmp
          BlinkCmpSource = { link = 'GruvboxGray' },
          BlinkCmpLabelDeprecated = { link = 'GruvboxGray' },
          BlinkCmpLabelDetail = { link = 'GruvboxGray' },
          BlinkCmpLabelDescription = { link = 'GruvboxGray' },
        },
      })
      vim.cmd.colorscheme('gruvbox')
    end,
  },
}
