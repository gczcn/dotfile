return {
  {
    'stevearc/oil.nvim',
    keys = {
      {
        '<leader>oe',
        function()
          if vim.o.filetype == 'oil' then
            vim.cmd([[bd]])
          else
            vim.cmd([[Oil]])
          end
        end,
        mode = 'n',
      },
    },
    cmd = 'Oil',
    config = function()
      require('oil').setup({
        default_file_explorer = false,
        view_options = {
          show_hidden = true,
        },
      })
    end
  }
}
