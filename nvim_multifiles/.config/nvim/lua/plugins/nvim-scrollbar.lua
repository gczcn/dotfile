return {
  'petertriho/nvim-scrollbar',
  event = 'VeryLazy',
  config = function()
    local change_highlight = function()
      local set_hl = vim.api.nvim_set_hl
      if vim.g.colors_name == 'gruvbox' then
        -- local palette = require('gruvbox').palette
        local get_hl = require('utils.get_hl')
        local bg = get_hl('GruvboxBg2')

        set_hl(0, 'ScrollbarHandle', { bg = bg, fg = get_hl('GruvboxGreen') })
        set_hl(0, 'ScrollbarCursor', { bg = bg, fg = get_hl('GruvboxGreen') })
        set_hl(0, 'ScrollbarCursorHandle', { bg = bg, fg = get_hl('GruvboxGreen') })
        set_hl(0, 'ScrollbarSearch', { bg = bg, fg = get_hl('GruvboxYellow') })
        set_hl(0, 'ScrollbarSearchHandle', { bg = bg, fg = get_hl('GruvboxYellow') })
        set_hl(0, 'ScrollbarErrorHandle', { bg = bg, fg = get_hl('GruvboxRed') })
        set_hl(0, 'ScrollbarWarnHandle', { bg = bg, fg = get_hl('GruvboxYellow') })
        set_hl(0, 'ScrollbarInfoHandle', { bg = bg, fg = get_hl('GruvboxBlue') })
        set_hl(0, 'ScrollbarHintHandle', { bg = bg, fg = get_hl('GruvboxAqua') })
        set_hl(0, 'ScrollbarMiscHandle', { bg = bg, fg = get_hl('GruvboxFg1') })
        set_hl(0, 'ScrollbarGitDeleteHandle', { bg = bg, link = 'ScrollbarErrorHandle' })
        set_hl(0, 'ScrollbarGitAddHandle', { bg = bg, fg = get_hl('GruvboxGreen') })
        set_hl(0, 'ScrollbarGitChangeHandle', { bg = bg, fg = get_hl('GruvboxOrange') })
      elseif vim.g.colors_name == 'onedark' then
        set_hl(0, 'ScrollbarHandle', { bg = '#373d49', fg = '#4966A0' })
        set_hl(0, 'ScrollbarCursor', { bg = '#373d49', fg = '#4966A0' })
        set_hl(0, 'ScrollbarCursorHandle', { bg = '#373d49', fg = '#4966A0' })
      else
        set_hl(0, 'ScrollbarHandle', { link = 'Pmenu' })
      end
    end

    require('scrollbar').setup({
      marks = {
        Cursor = { text = '━' },
        Search = { text = { '─', '═' }, },
        Error = { text = { '─', '═' }, },
        Warn = { text = { '─', '═' }, },
        Info = { text = { '─', '═' }, },
        Hint = { text = { '─', '═' }, },
        Misc = { text = { '─', '═' }, },
      },
      excluded_filetypes = {
        'blink-cmp-menu',
        'TelescopePrompt',
        'TelescopeResults',
        'TelescopePreview',
      },
    })
    change_highlight()
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = function()
        change_highlight()
      end
    })
  end
}
