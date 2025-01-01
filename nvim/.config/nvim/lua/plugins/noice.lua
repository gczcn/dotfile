return {
  {
    'folke/noice.nvim',
    enabled = true,
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    keys = {
      -- { '<leader>fn', '<cmd>NoiceFzf<CR>' },
      { '<S-Enter>', function() require('noice').redirect(vim.fn.getcmdline()) end, mode = 'c', desc = 'Redirect Cmdline' },
      { '<leader>anl', function() require('noice').cmd('last') end, desc = 'Noice Last Message' },
      { '<leader>anh', function() require('noice').cmd('history') end, desc = 'Noice History' },
      { '<leader>ana', function() require('noice').cmd('all') end, desc = 'Noice All' },
      -- { '<leader>and', function() require('noice').cmd('dismiss') end, desc = 'Dismiss All' },
      { '<c-f>', function() if not require('noice.lsp').scroll(4) then return '<c-f>' end end, silent = true, expr = true, desc = 'Scroll Forward', mode = {'i', 'n', 's'} },
      { '<c-b>', function() if not require('noice.lsp').scroll(-4) then return '<c-b>' end end, silent = true, expr = true, desc = 'Scroll Backward', mode = {'i', 'n', 's'}},
    },
    event = 'VeryLazy',
    opts = {
      cmdline = {
        format = {
          cmdline = { pattern = '^:', icon = '>', lang = 'vim' },
          search_down = { kind = "search", pattern = "^/", icon = " Up", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " Down", lang = "regex" },
          -- filter = { pattern = "^:%s*!", icon = " $", lang = "bash" },
          -- lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = " ", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "?" },
          -- input = { view = "cmdline", icon = " 󰥻 " },
        },
        -- view = 'cmdline',
      },
      views = {
        cmdline_popup = { border = { style = 'single', } },
        cmdline_input = { border = { style = 'single', } },
        confirm = { border = { style = 'single', } },
        popup_menu = { border = { style = 'single', } },
        -- hover = { border = { style = 'single', padding = { 0, 2 } } },
      },
      presets = {
        inc_rename = true,
        bottom_search = true,
        -- command_palette = true,
        long_message_to_split = true,
      },
    },
  },
}
