return {
  'stevearc/oil.nvim',
  keys = {
    {
      '<leader>te',
      function()
        if vim.o.filetype == 'oil' then
          require('oil').close()
        else
          require('oil').open()
        end
      end,
      mode = 'n',
    },
  },
  cmd = 'Oil',
  init = function()
    local oil_open_folder = function(path) require('oil').open(path) end
    require('utils.autocmd_attach_file_browser')('oil', oil_open_folder)
  end,
  config = function()
    require('oil').setup({
      columns = {
        "icon",
        "permissions",
        "size",
        -- "mtime",
      },
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      },
      confirmation = {
        border = 'single',
      },
    })
  end
}
