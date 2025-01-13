return {
  'saghen/blink.cmp',
  enabled = true,
  event = { 'InsertEnter', 'CmdlineEnter' },
  dependencies = {
    'rafamadriz/friendly-snippets',
    'L3MON4D3/LuaSnip',
    'giuxtaposition/blink-cmp-copilot',
    'zbirenbaum/copilot.lua',

    -- nvim-cmp sources
    'Saghen/blink.compat',
    'moyiz/blink-emoji.nvim',
  },
  build = 'rustup run nightly cargo build --release',
  -- build = 'cargo build --release',
  config = function()
    require('luasnip.loaders.from_vscode').lazy_load()
    require('blink.cmp').setup({
      appearance = {
        -- use_nvim_cmp_as_default = true,
        kind_icons = {
          Text = '󰉿',
          Method = '󰆧',
          Function = '󰊕',
          Constructor = '',
          Field = '󰜢',
          Variable = '󰀫',
          Class = '󰠱',
          Interface = '',
          Module = '',
          Property = '󰜢',
          Unit = '󰑭',
          Value = '󰎠',
          Enum = '',
          Keyword = '󰌋',
          Snippet = '',
          Color = '󰏘',
          File = '󰈙',
          Reference = '󰈇',
          Folder = '󰉋',
          EnumMember = '',
          Constant = '󰏿',
          Struct = '󰙅',
          Event = '',
          Operator = '󰆕',
          TypeParameter = '󰬛',
          Copilot = '',
        },
      },
      keymap = {
        preset = 'default',
        ['<M-.>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<S-TAB>'] = { 'select_prev', 'fallback' },
        ['<TAB>'] = { 'select_next', 'fallback' },
        ['<M-y>'] = { 'accept' },
      },
      completion = {
        list = {
          selection = { auto_insert = true, preselect = false },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 0,
          window = {
            -- border = 'single',
            winblend = vim.o.pumblend,
          },
        },
        menu = {
          draw = {
            padding = { 0, 1 },
            treesitter = { 'lsp' },
            columns = {
              { 'kind_icon' },
              { 'label', 'label_description', gap = 1 },
              -- { 'kind_icon', 'kind', gap = 1 },
              -- { 'source_name' },
            },
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  return ' ' .. ctx.kind_icon .. ' '
                end,
                highlight = function(ctx)
                  return require('blink.cmp.completion.windows.render.tailwind').get_hl(ctx)
                    or 'BlinkCmpKind' .. ctx.kind
                end,
              },
              source_name = {
                width = { max = 30 },
                text = function(ctx)
                  return '[' .. ctx.source_name .. ']'
                end,
                highlight = 'BlinkCmpSource',
              },
            },
          },
          -- border = 'single',
          winblend = vim.o.pumblend,
          max_height = 30,
        },
      },
      snippets = { preset = 'luasnip' },
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'copilot', 'emoji' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
          copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
            score_offset = 100,
            async = true,
            transform_items = function(_, items)
              local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
              local kind_idx = #CompletionItemKind + 1
              CompletionItemKind[kind_idx] = 'Copilot'
              for _, item in ipairs(items) do
                item.kind = kind_idx
              end
              return items
            end,
          },
          emoji = {
            module = 'blink-emoji',
            name = 'Emoji',
            score_offset = 15, -- Tune by preference
            opts = { insert = true }, -- Insert emoji (default) or complete its name
          },
        },
      },
    })
  end,
}
