return {
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    enabled = false,
    config = function()
      local palette = require('gruvbox').palette
      require('gruvbox').setup({
        italic = {
          strings = false,
        },
        overrides = {
          -- noice.nvim
          NoiceCmdlinePopupBorder = { link = 'Normal' },
          NoiceCmdlinePopupTitle = { link = 'Normal' },
          NoiceCmdlineIcon = { fg = palette.bright_orange },
          NoiceCmdlineIconLua = { fg = palette.bright_blue },
          NoiceCmdlineIconHelp = { fg = palette.bright_red },

          MiniIndentscopeSymbol = { fg = palette.bright_orange }, -- mini.indentscope
          LazyNormal = { link = 'Normal' }, -- lazy.nvim
          GitSignsCurrentLineBlame = { link = 'Comment' }, -- gitsigns

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

          -- nvim-cmp and blink.cmp
          -- CmpItemKindClass = { bg = palette.bright_yellow, fg = palette.dark1 },
          -- CmpItemKindColor = { bg = palette.bright_purple, fg = palette.dark1 },
          -- CmpItemKindConstant = { bg = palette.bright_orange, fg = palette.dark1 },
          -- CmpItemKindConstructor = { bg = palette.bright_yellow, fg = palette.dark1 },
          -- CmpItemKindEnum = { bg = palette.bright_yellow, fg = palette.dark1 },
          -- CmpItemKindEnumMember = { bg = palette.bright_aqua, fg = palette.dark1 },
          -- CmpItemKindEvent = { bg = palette.bright_purple, fg = palette.dark1 },
          -- CmpItemKindField = { bg = palette.bright_blue, fg = palette.dark1 },
          -- CmpItemKindFile = { bg = palette.bright_blue, fg = palette.dark1 },
          -- CmpItemKindFolder = { bg = palette.bright_blue, fg = palette.dark1 },
          -- CmpItemKindFunction = { bg = palette.bright_blue, fg = palette.dark1 },
          -- CmpItemKindInterface = { bg = palette.bright_yellow, fg = palette.dark1 },
          -- CmpItemKindKeyword = { bg = palette.bright_purple, fg = palette.dark1 },
          -- CmpItemKindMethod = { bg = palette.bright_blue, fg = palette.dark1 },
          -- CmpItemKindModule = { bg = palette.bright_blue, fg = palette.dark1 },
          -- CmpItemKindOperator = { bg = palette.bright_yellow, fg = palette.dark1 },
          -- CmpItemKindProperty = { bg = palette.bright_blue, fg = palette.dark1 },
          -- CmpItemKindReference = { bg = palette.bright_purple, fg = palette.dark1 },
          -- CmpItemKindSnippet = { bg = palette.bright_green, fg = palette.dark1 },
          -- CmpItemKindStruct = { bg = palette.bright_yellow, fg = palette.dark1 },
          -- CmpItemKindText = { bg = palette.bright_orange, fg = palette.dark1 },
          -- CmpItemKindTypeParameter = { bg = palette.bright_yellow, fg = palette.dark1 },
          -- CmpItemKindUnit = { bg = palette.bright_blue, fg = palette.dark1 },
          -- CmpItemKindValue = { bg = palette.bright_orange, fg = palette.dark1 },
          -- CmpItemKindVariable = { bg = palette.bright_orange, fg = palette.dark1 },
        },
      })
      vim.cmd.colorscheme('gruvbox')
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin-nvim',
    priority = 1000,
    enabled = false,
    config = function()
      require('catppuccin').setup({
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          mini = {
            enabled = true,
            indentscope_color = "",
          },

          mason = true,
          noice = true,
          notify = true,
        },
        custom_highlights = function(colors)
          return {
            -- Indent
            IblScope = { fg = colors.overlay0 },
            MiniIndentscopeSymbol = { fg = colors.pink },

            -- FzfLua
            FzfLuaHeaderText = { fg = colors.red },
            FzfLuaHeaderBind = { fg = colors.pink },
          }
        end,
      })
      vim.cmd.colorscheme('catppuccin')
    end,
  },
  {
    'neanias/everforest-nvim',
    priority = 1000,
    enabled = true,
    config = function()
      require('everforest').setup({
        on_highlights = function(hl, palette)
          hl.MiniIndentscopeSymbol = { fg = palette.green }
          hl.FzfLuaHeaderText = { fg = palette.red }
          hl.FzfLuaHeaderBind = { fg = palette.yellow }
          hl.IlluminatedWordText = { underline = true, bold = true }
          hl.IlluminatedWordRead = { underline = true, bold = true }
          hl.IlluminatedWordWrite = { underline = true, bold = true }
        end,
      })
      vim.cmd.colorscheme('everforest')
    end
  },
}
