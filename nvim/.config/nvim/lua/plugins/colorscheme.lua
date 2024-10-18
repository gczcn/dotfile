return {
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
          notify = false,
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
            IblScope = { fg = colors.overlay0 },
            MiniIndentscopeSymbol = { fg = colors.pink },
            NormalFloat = { link = 'Normal' },
          }
        end,
      })
      vim.cmd.colorscheme('catppuccin')
    end,
  },
  {
    'folke/tokyonight.nvim',
    enabled = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        style = 'night',
        lualine_bold = true,
        on_highlights = function(highlights, colors)
          highlights.IblScope = { fg = colors.comment }
          highlights.MiniStarterHeader = { link = 'Normal' }
          highlights.MiniStarterSection = { fg = colors.comment }
        end,
      })
      vim.cmd.colorscheme('tokyonight')
    end,
  },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    enabled = true,
    config = function()
      local v = vim.version()
      local palette = require('gruvbox').palette
      require('gruvbox').setup({
        italic = {
          strings = false,
        },
        overrides = {
          -- Visual = { bold = true },
          NoiceCmdlinePopupBorder = { link = 'Normal' },
          NoiceCmdlinePopupTitle = { link = 'Normal' },
          NoiceCmdlineIcon = { link = 'GruvboxOrange' },
          NoiceCmdlineIconLua = { link = 'GruvboxBlue' },
          NoiceCmdlineIconHelp = { link = 'GruvboxRed' },
          MiniIndentscopeSymbol = { link = 'GruvboxOrangeBold', bold = false },
          LazyNormal = { link = 'Normal' },
          GitSignsCurrentLineBlame = { link = 'Comment' },
          FloatBorder = { link = 'Normal' },
          NormalFloat = { link = 'Normal' },
        },
      })
      vim.cmd.colorscheme('gruvbox')
    end,
  },
  {
    'EdenEast/nightfox.nvim',
    priority = 1000,
    enabled = false,
    config = function()
      vim.cmd.colorscheme('terafox')
    end,
  },
}
