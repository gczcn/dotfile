return {
  'saghen/blink.cmp',
  -- enabled = false,
  event = 'InsertEnter',
  keys = {
    ':',
    '/',
    '?',
  },
  dependencies = {
    'rafamadriz/friendly-snippets',
    'L3MON4D3/LuaSnip',
  },
  build = 'rustup run nightly cargo build --release',
  -- build = 'cargo build --release',
  config = function()
    require('luasnip.loaders.from_vscode').lazy_load()
    require('blink.cmp').setup({
      appearance = {
        use_nvim_cmp_as_default = true,
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
          selection = 'auto_insert'
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
            -- padding = { 0, 1 },
            treesitter = { 'lsp' },
            columns = {
              -- { 'kind_icon' },
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', 'kind', gap = 1 },
              { 'source_name' },
            },
            components = {
              -- kind_icon = {
              --   ellipsis = false,
              --   text = function(ctx) return ' ' .. ctx.kind_icon .. ' ' end,
              --   highlight = function(ctx)
              --     return require('blink.cmp.completion.windows.render.tailwind').get_hl(ctx) or 'BlinkCmpKind' .. ctx.kind
              --   end,
              -- },
            },
          },
          -- border = 'single',
          winblend = vim.o.pumblend,
          max_height = 30,
        },
      },
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'luasnip', 'buffer' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
        },
      },
    })
  end
}
