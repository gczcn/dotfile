return {
  {
    'catppuccin/nvim',
    name = 'catppuccin-nvim',
    priority = 1000,
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
            MiniIndentscopeSymbol = { fg = colors.overlay1 },
            -- CursorColumn = { link = 'CursorLine' }
          }
        end,
      })
      vim.cmd.colorscheme('catppuccin')
    end
  }
}
