return {
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    enabled = true,
    config = function()
      local palette = require('gruvbox').palette
      require('gruvbox').setup({
        italic = {
          strings = false,
          comments = true,
        },
        overrides = {
          CursorLineNr = { bold = true },
          -- LineNr = { bg = palette.dark1 },

          -- noice.nvim
          NoiceCmdlinePopupBorder = { link = 'Normal' },
          NoiceCmdlinePopupTitle = { link = 'Normal' },
          NoiceCmdlineIcon = { fg = palette.bright_orange },
          NoiceCmdlineIconLua = { fg = palette.bright_blue },
          NoiceCmdlineIconHelp = { fg = palette.bright_red },

          -- FzfLua
          FzfLuaHeaderText = { fg = palette.bright_red },
          FzfLuaHeaderBind = { fg = palette.bright_orange },

          -- Lualine
          -- check https://github.com/nvim-lualine/lualine.nvim/issues/1312 for more information
          StatusLine = { reverse = false },
          StatusLineNC = { reverse = false },

          -- vim-illuminate
          IlluminatedWordText = { underline = true },
          IlluminatedWordRead = { underline = true },
          IlluminatedWordWrite = { underline = true },

          -- gitsigns.nvim
          GitSignsCurrentLineBlame = { fg = palette.dark4 },

          -- flash.nvim
          FlashLabel = { bg = palette.bright_red, fg = palette.dark0 },

          -- blink.cmp
          BlinkCmpKindClass = { bg = palette.bright_yellow, fg = palette.dark1 },
          BlinkCmpKindColor = { bg = palette.bright_purple, fg = palette.dark1 },
          BlinkCmpKindConstant = { bg = palette.bright_orange, fg = palette.dark1 },
          BlinkCmpKindConstructor = { bg = palette.bright_yellow, fg = palette.dark1 },
          BlinkCmpKindEnum = { bg = palette.bright_yellow, fg = palette.dark1 },
          BlinkCmpKindEnumMember = { bg = palette.bright_aqua, fg = palette.dark1 },
          BlinkCmpKindEvent = { bg = palette.bright_purple, fg = palette.dark1 },
          BlinkCmpKindField = { bg = palette.bright_blue, fg = palette.dark1 },
          BlinkCmpKindFile = { bg = palette.bright_blue, fg = palette.dark1 },
          BlinkCmpKindFolder = { bg = palette.bright_blue, fg = palette.dark1 },
          BlinkCmpKindFunction = { bg = palette.bright_blue, fg = palette.dark1 },
          BlinkCmpKindInterface = { bg = palette.bright_yellow, fg = palette.dark1 },
          BlinkCmpKindKeyword = { bg = palette.bright_purple, fg = palette.dark1 },
          BlinkCmpKindMethod = { bg = palette.bright_blue, fg = palette.dark1 },
          BlinkCmpKindModule = { bg = palette.bright_blue, fg = palette.dark1 },
          BlinkCmpKindOperator = { bg = palette.bright_yellow, fg = palette.dark1 },
          BlinkCmpKindProperty = { bg = palette.bright_blue, fg = palette.dark1 },
          BlinkCmpKindReference = { bg = palette.bright_purple, fg = palette.dark1 },
          BlinkCmpKindSnippet = { bg = palette.bright_green, fg = palette.dark1 },
          BlinkCmpKindStruct = { bg = palette.bright_yellow, fg = palette.dark1 },
          BlinkCmpKindText = { bg = palette.bright_orange, fg = palette.dark1 },
          BlinkCmpKindTypeParameter = { bg = palette.bright_yellow, fg = palette.dark1 },
          BlinkCmpKindUnit = { bg = palette.bright_blue, fg = palette.dark1 },
          BlinkCmpKindValue = { bg = palette.bright_orange, fg = palette.dark1 },
          BlinkCmpKindVariable = { bg = palette.bright_orange, fg = palette.dark1 },
          BlinkCmpKindCopilot = { bg = palette.light3, fg = palette.dark1 },
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
