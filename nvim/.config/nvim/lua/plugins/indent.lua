return {
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'User FileOpened',
    config = function()
      require('ibl').setup({
        indent = {
          char = '│',
          tab_char = '>',
        },
        -- -- Background color indentation guides
        -- indent = {
        --   highlight = { 'CursorColumn', 'Whitespace' },
        --   char = '',
        --   tab_char = '>', },
        -- whitespace = {
        --   highlight = { 'CursorColumn', 'Whitespace' },
        --   remove_blankline_trail = false,
        -- },
        -- scope = { enabled = false },
      })
    end
  },
  {
    'echasnovski/mini.indentscope',
    event = 'User FileOpened',
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'help',
          'alpha',
          'dashboard',
          'starter',
          'neo-tree',
          'Trouble',
          'trouble',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'lazyterm',
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
    config = function()
      require('mini.indentscope').setup({
        symbol = '│',
        -- symbol = '▏',
        options = {
          indent_at_cursor = false,
        },
        draw = {
          delay = 0,
          animation = require('mini.indentscope').gen_animation.none(),
        },
        mappings = {
          -- Textobjects
          object_scope = '',
          object_scope_with_border = '',

          -- Motions (jump to respective border line; if not present - body line)
          goto_top = '[i',
          goto_bottom = ']i',
        },
      })
    end
  },
}
