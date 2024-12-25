if true then return {} end

return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- 'nvim-tree/nvim-web-devicons',
      'echasnovski/mini.icons',

      'nvim-telescope/telescope-file-browser.nvim'
    },
    branch = 'master',
    cmd = 'Telescope',
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<CR>' },
      { '<leader>fr', '<cmd>Telescope oldfiles<CR>' },
      { '<leader>fs', '<cmd>Telescope live_grep<CR>' },
      { '<leader>fc', '<cmd>Telescope grep_string<CR>' },
      { '<leader>fk', '<cmd>Telescope keymaps<CR>' },
      { '<leader>fh', '<cmd>Telescope help_tags<CR>' },
      { '<leader>fo', '<cmd>Telescope find_files cwd=' .. vim.fn.stdpath 'config' .. '<CR>' },
      { '<leader>fb', '<cmd>Telescope buffers<CR>' },
      { '<leader>fw', '<cmd>Telescope colorscheme<CR>' },

      { '<leader>fe', '<cmd>Telescope file_browser<CR>' },
      { '<leader>fE', '<cmd>Telescope file_browser path=%:p:h<CR>' },
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
      local load_extension = telescope.load_extension
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
          }
        },
      })

      -- Neovide
      if vim.g.neovide then
        telescope.setup({
          defaults = {
            winblent = 30,
          },
        })
      end

      load_extension('file_browser')
    end
  }
}
