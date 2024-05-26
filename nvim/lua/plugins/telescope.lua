return {
  {
    'nvim-telescope/telescope.nvim',
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
      { '<leader>tG', '<cmd>Telescope glyph<CR>' },
      { '<leader>tb', '<cmd>Telescope bookmarks list<CR>' },
      { '<leader>tg', '<cmd>Telescope nerdy<CR>' },
      -- { '<leader>ta', '<cmd>Telescope aerial<CR>' },
      { '<leader>tz', '<cmd>Telescope z<CR>' },
      { '<leader>th', '<cmd>Telescope help_tags<CR>' },
      { '<leader>to', '<cmd>Telescope find_files cwd=' .. vim.fn.stdpath 'config' .. '<CR>' }
    },
    branch = '0.1.x',
    dependencies = {
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-lua/plenary.nvim',
      -- 'nvim-tree/nvim-web-devicons',
      { 'kkharji/sqlite.lua', module = 'sqlite' },
      'AckslD/nvim-neoclip.lua',
      'debugloop/telescope-undo.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
      'xiyaowong/telescope-emoji.nvim',
      'ghassan0/telescope-glyph.nvim',
      'tomasky/bookmarks.nvim',
      '2kabhishek/nerdy.nvim',
      'stevearc/dressing.nvim',
      -- 'stevearc/aerial.nvim',
      'nvim-telescope/telescope-z.nvim',
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
            winblend = 70,
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

      telescope.load_extension('fzf')
      telescope.load_extension('neoclip')
      telescope.load_extension('undo')
      telescope.load_extension('file_browser')
      telescope.load_extension('emoji')
      telescope.load_extension('glyph')
      telescope.load_extension('bookmarks')
      telescope.load_extension('nerdy')
      -- telescope.load_extension('aerial')
      telescope.load_extension('z')
    end,
  }
}
