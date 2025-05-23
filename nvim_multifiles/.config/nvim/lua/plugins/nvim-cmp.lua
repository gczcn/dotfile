return {
  -- 'hrsh7th/nvim-cmp',
  'iguanacucumber/magazine.nvim',
  -- 'xzbdmw/nvim-cmp',
  enabled = false,
  name = 'nvim-cmp',
  event = { 'InsertEnter', 'CmdlineEnter' },
  -- keys = {
  --   ':',
  --   '/',
  --   '?',
  -- },
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      build = 'make install_jsregexp',
    },

    -- magazine.nvim
    { 'iguanacucumber/mag-nvim-lua', name = 'cmp-nvim-lua' },
    { 'iguanacucumber/mag-buffer', name = 'cmp-buffer' },
    { 'iguanacucumber/mag-cmdline', name = 'cmp-cmdline' },
    { 'iguanacucumber/mag-nvim-lsp', name = 'cmp-nvim-lsp', opts = {} },

    -- 'hrsh7th/cmp-buffer', -- source for text in buffer
    -- 'hrsh7th/cmp-nvim-lua', -- nvim-cmp source for neovim Lua API
    -- 'hrsh7th/cmp-cmdline',
    -- 'hrsh7th/cmp-nvim-lsp',

    { url = 'https://codeberg.org/FelipeLema/cmp-async-path' },
    'rafamadriz/friendly-snippets', -- useful snippets
    'saadparwaiz1/cmp_luasnip', -- for autocompletion
    'hrsh7th/cmp-calc', -- nvim-cmp source for math calculation.
    'hrsh7th/cmp-emoji',
    'ray-x/cmp-treesitter',
    { 'zbirenbaum/copilot-cmp', config = function() require("copilot_cmp").setup() end },
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
      KeywordConditional = ' ',
      Copilot = ''
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
            async_path = '[AsyncPath]',
            buffer = '[Buffer]',
            nvim_lua = '[Lua]',
            latex_symbols = '[Latex]',
            calc = '[Calc]',
            emoji = '[Emoji]',
            treesitter = '[Treesitter]',
            cmp_tabnine = '[Tabnine]',
            copilot = '[Copilot]',
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
        -- documentation = cmp.config.window.bordered({ border = 'single' }),
        -- completion = cmp.config.window.bordered({
        --   winhighlight = 'Normal:CmpPmenu,CursorLine:PmenuSel,Search:None',
        --   border = 'single',
        --   col_offset = -1,
        --   scrolloff = 4,
        -- }),
        completion = {
          scrolloff = 3,
        },
      },
      mapping = cmp.mapping.preset.insert({
        ['<S-TAB>'] = cmp.mapping.select_prev_item(), -- previous suggestion
        ['<TAB>'] = cmp.mapping.select_next_item(), -- next suggestion
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<M-.>'] = cmp.mapping.complete(), -- show completion suggestions
        ['<M-e>'] = cmp.mapping.abort(), -- close completion window
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
      }),
      sources = cmp.config.sources({
        { name = 'copilot' },
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- snippets
        { name = 'nvim_lua' },
        -- { name = 'path' },
        { name = 'async_path' },
        { name = 'buffer' },
        { name = 'treesitter' },
        { name = 'calc' },
        { name = 'emoji' },
      }),
      performance = {
        debounce = 0,
      },
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
