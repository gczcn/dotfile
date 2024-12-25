return {
  {
    'folke/noice.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>fn', 'NoiceFzf' },
    },
    event = 'VeryLazy',
    opts = {
      cmdline = {
        format = {
          cmdline = { pattern = '^:', icon = '>', lang = 'vim' },
          search_down = { kind = "search", pattern = "^/", icon = "Up", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = "Down", lang = "regex" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "?" },
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
