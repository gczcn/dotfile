return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  keys = {
    ':',
    '/',
    '?',
  },
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      build = 'make install_jsregexp',
    },
    'rafamadriz/friendly-snippets', -- useful snippets
    'saadparwaiz1/cmp_luasnip', -- for autocompletion
    'hrsh7th/cmp-buffer', -- source for text in buffer
    'hrsh7th/cmp-path', -- source for file system paths
    'hrsh7th/cmp-calc', -- nvim-cmp source for math calculation.
    'hrsh7th/cmp-emoji',
    'hrsh7th/cmp-nvim-lua', -- nvim-cmp source for neovim Lua API
    'hrsh7th/cmp-cmdline',
    -- 'hrsh7th/nvim-lsp',
    'ray-x/cmp-treesitter',
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require('luasnip.loaders.from_vscode').lazy_load()

    local kind_icons = {
      Text = '󰉿',
      Method = '󰆧',
      Function = '󰊕',
      Constructor = '',
      Comment = '',
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
      String = '󰅳',
      Struct = '󰙅',
      Event = '',
      Operator = '󰆕',
      TabNine = 'A',
      TypeParameter = '',
      Number = '0',
      KeywordConditional = ' '
    }
    local custom_kind = {
      calc = '󰃬 Calc'
    }

    cmp.setup({
      formatting = {
        format = function(entry, vim_item)
          vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
          if custom_kind[entry.source.name] ~= nil then
            vim_item.kind = custom_kind[entry.source.name]
          end
          vim_item.menu = ({
            nvim_lsp = '[LSP]',
            luasnip = '[LuaSnip]',
            path = '[Path]',
            buffer = '[Buffer]',
            nvim_lua = '[Lua]',
            latex_symbols = '[Latex]',
            calc = '[Calc]',
            emoji = '[Emoji]',
            treesitter = '[Treesitter]',
            cmp_tabnine = '[Tabnine]',
          })[entry.source.name]
          return vim_item
        end,
      },
      completion = {
        completeopt = 'menu,menuone,preview,noselect',
      },
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end
      },
      view = {
        entries = { name = 'custom', selection_order = 'near_cursor' },
      },
      window = {
        documentation = cmp.config.window.bordered({ border = 'single' }),
        completion = cmp.config.window.bordered({
          winhighlight = 'Normal:CmpPmenu,CursorLine:PmenuSel,Search:None',
          border = 'single',
          col_offset = -1,
        }),
      },
      mapping = cmp.mapping.preset.insert({
        ['<S-TAB>'] = cmp.mapping.select_prev_item(), -- previous suggestion
        ['<TAB>'] = cmp.mapping.select_next_item(), -- next suggestion
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<M-o>'] = cmp.mapping.complete(), -- show completion suggestions
        ['<M-e>'] = cmp.mapping.abort(), -- close completion window
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
      }),
      sources = cmp.config.sources({
        { name = 'luasnip' }, -- snippets
        { name = 'nvim_lua' },
        { name = 'path' },
        { name = 'buffer' },
        { name = 'treesitter' },
        { name = 'calc' },
        { name = 'emoji' },
      }),
    })

    -- `/` cmdline setup.
    cmp.setup.cmdline('/', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })

    -- `:` cmdline setup.
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        {
          name = 'cmdline',
          option = {
            ignore_cmds = { 'Man', '!' }
          }
        }
      })
    })
  end,
}
