return {
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    -- event = 'VeryLazy',
    cmd = 'Telescope',
    keys = {
      { '<leader>tf', '<cmd>Telescope find_files<CR>' },
      { '<leader>tr', '<cmd>Telescope oldfiles<CR>' },
      { '<leader>ts', '<cmd>Telescope live_grep<CR>' },
      { '<leader>tc', '<cmd>Telescope grep_string<CR>' },
      { '<leader>tk', '<cmd>Telescope keymaps<CR>' },
      { '<leader>tn', '<cmd>Telescope notify<CR>' },
      { '<leader>ty', '<cmd>Telescope neoclip<CR>', mode = 'n' },
      { '<leader>tu', '<cmd>Telescope undo<CR>' },
      { '<leader>te', '<cmd>Telescope file_browser<CR>' },
      { '<leader>tE', '<cmd>Telescope file_browser path=%:p:h<CR>' },
      { '<leader>tj', '<cmd>Telescope emoji<CR>' },
      { '<leader>tg', '<cmd>Telescope glyph<CR>' },
      { '<leader>tG', '<cmd>Telescope nerdy<CR>' },
      -- { '<leader>ta', '<cmd>Telescope aerial<CR>' },
      { '<leader>tz', '<cmd>Telescope zoxide list<CR>' },
      { '<leader>th', '<cmd>Telescope help_tags<CR>' },
      { '<leader>to', '<cmd>Telescope find_files cwd=' .. vim.fn.stdpath 'config' .. '<CR>' },
      { '<leader>tb', '<cmd>Telescope buffers<CR>' },
      { '<leader>tw', function()
        vim.api.nvim_exec_autocmds('User', { pattern = 'LoadColors' })
        vim.cmd('Telescope colorscheme')
      end },
    },
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'stevearc/dressing.nvim',
      { 'kkharji/sqlite.lua', module = 'sqlite' },

      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'AckslD/nvim-neoclip.lua',
      'debugloop/telescope-undo.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
      'xiyaowong/telescope-emoji.nvim',
      'ghassan0/telescope-glyph.nvim',
      '2kabhishek/nerdy.nvim',
      -- 'stevearc/aerial.nvim',
      'jvgrootveld/telescope-zoxide',
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
          zoxide = {
            prompt_title = 'Visited directories from zoxide',
            mappings = {
              default = {
                action = function(selection)
                  vim.cmd.cd(selection.path)
                  vim.fn.system({ "zoxide", "add", selection.path })
                  vim.cmd('Telescope find_files')
                end,
              },
            },
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

      -- neoclip config
      require('neoclip').setup({
        history = 1000,
        enable_persistent_history = true,
        keys = {
          telescope = {
            i = {
              select = '<c-y>',
              paste = '<cr>',
              paste_behind = '<c-g>',
              replay = '<c-q>', -- replay a macro
              delete = '<c-d>', -- delete an entry
              edit = '<c-k>', -- edit an entry
              custom = {},
            },
          },
        },
      })

      local load_extension = telescope.load_extension

      load_extension('fzf')
      load_extension('neoclip')
      load_extension('undo')
      load_extension('file_browser')
      load_extension('emoji')
      load_extension('glyph')
      load_extension('nerdy')
      load_extension('zoxide')
      -- load_extension('aerial')
    end,
  }
}
