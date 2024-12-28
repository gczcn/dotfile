return {
  {
    'folke/noice.nvim',
    enabled = true,
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    keys = {
      -- { '<leader>fn', '<cmd>NoiceFzf<CR>' },
    },
    event = 'VeryLazy',
    opts = {
      cmdline = {
        format = {
          cmdline = { pattern = '^:', icon = ' >', lang = 'vim' },
          search_down = { kind = "search", pattern = "^/", icon = " Up", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " Down", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = " $", lang = "bash" },
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = " ", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = " ?" },
          input = { view = "cmdline_input", icon = " 󰥻 " },
        },
        view = 'cmdline',
      },
      views = {
        cmdline_popup = { border = { style = 'single', } },
        cmdline_input = { border = { style = 'single', } },
        confirm = { border = { style = 'single', } },
        popup_menu = { border = { style = 'single', } },
        -- hover = { border = { style = 'single', padding = { 0, 2 } } },
      },
      presets = {
        bottom_search = true,
        -- command_palette = true,
        long_message_to_split = true,
      },
    },
  },
}
