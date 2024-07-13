return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    keys = {
      { '<leader>tf', '<cmd>Telescope find_files<CR>' },
      { '<leader>tr', '<cmd>Telescope oldfiles<CR>' },
      { '<leader>ts', '<cmd>Telescope live_grep<CR>' },
      { '<leader>tc', '<cmd>Telescope grep_string<CR>' },
      { '<leader>tk', '<cmd>Telescope keymaps<CR>' },
      { '<leader>te', '<cmd>Telescope file_browser<CR>' },
      { '<leader>tE', '<cmd>Telescope file_browser path=%:p:h<CR>' },
      -- { '<leader>ta', '<cmd>Telescope aerial<CR>' },
      { '<leader>th', '<cmd>Telescope help_tags<CR>' },
      { '<leader>to', '<cmd>Telescope find_files cwd=' .. vim.fn.stdpath 'config' .. '<CR>' },
      { '<leader>tb', '<cmd>Telescope buffers<CR>' },
      { '<leader>tw', function()
        vim.api.nvim_exec_autocmds('User', { pattern = 'LoadColors' })
        vim.cmd('Telescope colorscheme')
      end },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',

      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-file-browser.nvim',
    },
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == 'directory' then
          require('telescope')
        end
      end
    end,
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      telescope.setup({
        defaults = {
          borderchars = {
            prompt = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
            results = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
            preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
          },
          mappings = {
            i = {
              ['<M-u>'] = actions.move_selection_previous,
              ['<M-e>'] = actions.move_selection_next,
            },
          },
          winblend = 15,
        },
        extensions = {
          file_browser = {
            hijack_netrw = true,
            hidden = { file_browser = true, folder_browser = true },
          },
        },
      })

      if vim.g.neovide then
        telescope.setup({
          defaults = {
            winblend = 30,
          },
        })
      end

      local load_extension = telescope.load_extension

      load_extension('fzf')
      load_extension('file_browser')
      -- load_extension('aerial')
    end,
  }
}
