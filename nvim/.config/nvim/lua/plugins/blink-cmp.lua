return {
  'saghen/blink.cmp',
  enabled = true,
  event = { 'InsertEnter', 'CmdlineEnter' },
  dependencies = {
    'rafamadriz/friendly-snippets',
    'L3MON4D3/LuaSnip',
    { 'giuxtaposition/blink-cmp-copilot', enabled = vim.g.enabled_copilot },
    { 'zbirenbaum/copilot.lua', enabled = vim.g.enabled_copilot },
    'moyiz/blink-emoji.nvim',

    -- nvim-cmp sources
    { 'Saghen/blink.compat', opts = { impersonate_nvim_cmp = true } },
    -- { 'tzachar/cmp-tabnine', enabled = vim.g.enabled_tabnine, build = './install.sh' },
  },
  build = 'rustup run nightly cargo build --release',
  -- build = 'cargo build --release',
  config = function()
    require('luasnip.loaders.from_vscode').lazy_load()

    local get_default_sources = function()
      local sources = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'emoji' }

      if vim.g.enabled_copilot then
        table.insert(sources, 'copilot')
      end

      -- if vim.g.enabled_tabnine then
      --   table.insert(sources, 'cmp_tabnine')
      -- end

      return sources
    end

    local opts = {
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
            treesitter = { 'lsp', 'copilot', 'cmp_tabnine', 'snippets' },
            columns = {
              { 'kind_icon' },
              { 'label', 'label_description', gap = 1 },
              -- { 'kind_icon', 'kind', gap = 1 },
              { 'source_name' },
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
        default = get_default_sources(),
        providers = {
          lazydev = {
            name = 'lazydev',
            module = 'lazydev.integrations.blink',
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
          emoji = {
            module = 'blink-emoji',
            name = 'Emoji',
            score_offset = 15, -- Tune by preference
            opts = { insert = true }, -- Insert emoji (default) or complete its name
          },
        },
      },
    }

    if vim.g.enabled_copilot then
      opts.sources.provides.copilot = {
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
      }
    end

    -- if vim.g.enabled_tabnine then
    --   opts.sources.providers.cmp_tabnine = {
    --     name = 'cmp_tabnine',
    --     module = 'blink.compat.source',
    --     score_offset = -3,
    --   }
    -- end

    require('blink.cmp').setup(opts)
  end,
}
