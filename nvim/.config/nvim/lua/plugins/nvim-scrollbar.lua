local change_highlight = function()
  if vim.g.colors_name == 'gruvbox' then
    -- local palette = require('gruvbox').palette
    local get_hl = require('utils.get_hl')
    local bg = get_hl('GruvboxBg2')

    vim.api.nvim_set_hl(0, 'ScrollbarHandle', { bg = bg, fg = get_hl('GruvboxGreen') })
    vim.api.nvim_set_hl(0, 'ScrollbarCursor', { bg = bg, fg = get_hl('GruvboxGreen') })
    vim.api.nvim_set_hl(0, 'ScrollbarCursorHandle', { bg = bg, fg = get_hl('GruvboxGreen') })
    vim.api.nvim_set_hl(0, 'ScrollbarSearch', { bg = bg, fg = get_hl('GruvboxYellow') })
    vim.api.nvim_set_hl(0, 'ScrollbarSearchHandle', { bg = bg, fg = get_hl('GruvboxYellow') })
    vim.api.nvim_set_hl(0, 'ScrollbarError', { fg = get_hl('GruvboxRed') })
    vim.api.nvim_set_hl(0, 'ScrollbarErrorHandle', { fg = get_hl('GruvboxRed') })
    vim.api.nvim_set_hl(0, 'ScrollbarWarn', { fg = get_hl('GruvboxYellow') })
    vim.api.nvim_set_hl(0, 'ScrollbarWarnHandle', { fg = get_hl('GruvboxYellow') })
    vim.api.nvim_set_hl(0, 'ScrollbarInfo', { fg = get_hl('GruvboxBlue') })
    vim.api.nvim_set_hl(0, 'ScrollbarInfoHandle', { fg = get_hl('GruvboxBlue') })
    vim.api.nvim_set_hl(0, 'ScrollbarHint', { fg = get_hl('GruvboxAqua') })
    vim.api.nvim_set_hl(0, 'ScrollbarHintHandle', { fg = get_hl('GruvboxAqua') })
    vim.api.nvim_set_hl(0, 'ScrollbarMisc', { fg = get_hl('GruvboxFg1') })
    vim.api.nvim_set_hl(0, 'ScrollbarMiscHandle', { fg = get_hl('GruvboxFg1') })
    vim.api.nvim_set_hl(0, 'ScrollbarGitDelete', { link = 'ScrollbarError' })
    vim.api.nvim_set_hl(0, 'ScrollbarGitDeleteHandle', { link = 'ScrollbarErrorHandle' })
    vim.api.nvim_set_hl(0, 'ScrollbarGitAdd', { fg = get_hl('GruvboxGreen') })
    vim.api.nvim_set_hl(0, 'ScrollbarGitAddHandle', { fg = get_hl('GruvboxGreen') })
    vim.api.nvim_set_hl(0, 'ScrollbarGitChange', { fg = get_hl('GruvboxOrange') })
    vim.api.nvim_set_hl(0, 'ScrollbarGitChangeHandle', { fg = get_hl('GruvboxOrange') })
  elseif vim.g.colors_name == 'onedark' then
    vim.api.nvim_set_hl(0, 'ScrollbarHandle', { bg = '#373d49', fg = '#4966A0' })
    vim.api.nvim_set_hl(0, 'ScrollbarCursor', { bg = '#373d49', fg = '#4966A0' })
    vim.api.nvim_set_hl(0, 'ScrollbarCursorHandle', { bg = '#373d49', fg = '#4966A0' })
  else
    vim.api.nvim_set_hl(0, 'ScrollbarHandle', { link = 'Pmenu' })
  end
end

return {
  'petertriho/nvim-scrollbar',
  event = 'VeryLazy',
  config = function()
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
