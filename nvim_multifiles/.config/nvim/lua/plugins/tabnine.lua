return {
  'codota/tabnine-nvim',
  enabled = vim.g.enabled_tabnine,
  build = './dl_binaries.sh',
  config = function()
    require('tabnine').setup({
      disable_auto_comment = true,
      accept_keymap = '<M-a>',
      dismiss_keymap = '<C-]>',
      debounce_ms = 800,
      suggestion_color = { gui = require('utils.get_hl')('Comment'), cterm = 244 },
      exclude_filetypes = { 'TelescopePrompt', 'NvimTree', 'fzf' },
      log_file_path = nil, -- absolute path to Tabnine log file
      ignore_certificate_errors = false,
    })
  end,
}
