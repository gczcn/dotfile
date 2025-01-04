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
    _G.get_oil_winbar = function()
      local dir = require("oil").get_current_dir()
      if dir then
        return vim.fn.fnamemodify(dir, ":~")
      else
        -- If there is no current directory (e.g. over ssh), just show the buffer name
        return vim.api.nvim_buf_get_name(0)
      end
    end
    require('oil').setup({
      -- columns = {
      --   "icon",
      --   "permissions",
      --   "size",
      --   -- "mtime",
      -- },
      win_options = {
        winbar = "%!v:lua.get_oil_winbar()",
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
