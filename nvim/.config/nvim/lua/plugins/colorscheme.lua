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
          -- comments = false,
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
          GitSignsCurrentLineBlame = { fg = palette.dark4 }, -- gitsigns

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
    enabled = false,
    config = function()
      require('everforest').setup({
        background = 'hard',
        on_highlights = function(hl, palette)
          -- fzf-lua
          hl.FzfLuaHeaderText = { fg = palette.red }
          hl.FzfLuaHeaderBind = { fg = palette.yellow }

          -- vim-illuminate
          hl.IlluminatedWordText = { underline = true }
          hl.IlluminatedWordRead = { underline = true }
          hl.IlluminatedWordWrite = { underline = true }
        end,
      })
      vim.api.nvim_create_autocmd('Colorscheme', {
        pattern = 'everforest',
        callback = function()
          vim.g.terminal_color_0  = '#414b50'
          vim.g.terminal_color_1  = '#e67e80'
          vim.g.terminal_color_2  = '#a7c080'
          vim.g.terminal_color_3  = '#dbbc7f'
          vim.g.terminal_color_4  = '#7fbbb3'
          vim.g.terminal_color_5  = '#d699b6'
          vim.g.terminal_color_6  = '#83c092'
          vim.g.terminal_color_7  = '#d3c6aa'
          vim.g.terminal_color_8  = '#475258'
          vim.g.terminal_color_9  = '#e67e80'
          vim.g.terminal_color_10 = '#a7c080'
          vim.g.terminal_color_11 = '#dbbc7f'
          vim.g.terminal_color_12 = '#7fbbb3'
          vim.g.terminal_color_13 = '#d699b6'
          vim.g.terminal_color_14 = '#83c092'
          vim.g.terminal_color_15 = '#d3c6aa'
        end
      })
      vim.cmd.colorscheme('everforest')
    end
  },
  {
    'sainnhe/gruvbox-material',
    priority = 1000,
    enabled = false,
    config = function()
      vim.g.gruvbox_material_better_performance = 1
      -- vim.g.gruvbox_material_background = 'hard'
      -- vim.g.gruvbox_material_foreground = 'mix'

      vim.api.nvim_create_autocmd('Colorscheme', {
        group = vim.api.nvim_create_augroup('custom_highlights_gruvboxmaterial', {}),
        pattern = 'gruvbox-material',
        callback = function()
          local config = vim.fn['gruvbox_material#get_configuration']()
          local palette = vim.fn['gruvbox_material#get_palette'](config.background, config.foreground, config.colors_override)
          local set_hl = vim.fn['gruvbox_material#highlight']

          set_hl('FzfLuaHeaderText', palette.red, palette.none)
          set_hl('FzfLuaHeaderBind', palette.orange, palette.none)
        end
      })

      vim.cmd.colorscheme('gruvbox-material')
    end
  },
}
