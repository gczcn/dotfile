return {
  {
    'echasnovski/mini.starter',
    config = function()
      local Utils = require('utils')

      local starter = require('mini.starter')

      local version = function()
        return 'nvim v'
          .. vim.version().major
          .. '.'
          .. vim.version().minor
          .. '.'
          .. vim.version().patch
          .. '-'
          .. vim.version().prerelease
          .. '+'
          .. vim.version().build
      end

      local date = function()
        return os.date()
      end

      local footer = function()
        return version() .. '\n' .. date()
      end

      local recent_files = function(n, current_dir, show_path)
        n = n or 5
        if current_dir == nil then current_dir = false end

        if show_path == nil then show_path = true end
        if show_path == false then show_path = function() return '' end end
        if show_path == true then
          show_path = function(path) return string.format(' (%s)', vim.fn.fnamemodify(path, ':~:.')) end
        end

        return function()
          local section = string.format('Recent files%s', current_dir and ' ' .. current_dir or '')

          -- Use only actual readable files
          local files = vim.tbl_filter(function(f) return vim.fn.filereadable(f) == 1 end, vim.v.oldfiles or {})

          if #files == 0 then
            return { { name = 'There are no recent files (`v:oldfiles` is empty)', action = '', section = section } }
          end

          -- Possibly filter files from current directory
          if current_dir then
            local sep = vim.loop.os_uname().sysname == 'Windows_NT' and [[%\]] or '%/'
            local cwd_pattern = '^' .. vim.pesc(vim.fn.getcwd()) .. sep
            -- Use only files from current directory and its subdirectories
            files = vim.tbl_filter(function(f) return f:find(cwd_pattern) ~= nil end, files)
          end

          if #files == 0 then
            return { { name = 'There are no recent files in current directory', action = '', section = section } }
          end

          -- Create items
          local items = {}
          for _, f in ipairs(vim.list_slice(files, 1, n)) do
            local name = vim.fn.fnamemodify(f, ':t') .. show_path(f)
            table.insert(items, { action = 'edit ' .. f, name = name, section = section })
          end

          return items
        end
      end

      local opts = {
        items = {
          -- Recent files (Current directory)
          recent_files(8, vim.fn.getcwd()),

          -- Recent files
          recent_files(8),

          -- Builtin actions
          { name = 'Edit new buffer', action = ':ene', section = 'Builtin actions' },
          { name = 'Quit Neovim', action = ':q', section = 'Builtin actions' },

          -- Plugins actions
          { name = 'Sync Plugins', action = ':Lazy sync', section = 'Plugins actions' },
          { name = 'Lazy', action = ':Lazy', section = 'Plugins actions' },
          { name = 'Mason', action = ':Mason', section = 'Plugins actions' },

          -- Telescope
          { name = 'Jump', action = ':Telescope z', section = 'Telescope' },
          { name = 'Explore', action = ':Telescope file_browser', section = 'Telescope' },
          { name = 'Find files', action = ':Telescope find_files', section = 'Telescope' },
          { name = 'Live grep', action = ':Telescope live_grep', section = 'Telescope' },
          { name = 'Grep string', action = ':Telescope grep_string', section = 'Telescope' },
          { name = 'Recent files', action = ':Telescope oldfiles', section = 'Telescope' },
          { name = 'Bookmarks', action = ':Telescope bookmarks list', section = 'Telescope' },
          { name = 'Options', action = ':Telescope find_files cwd=' .. vim.fn.stdpath('config'), section = 'Telescope' },
        },
        content_hooks = {
          starter.gen_hook.adding_bullet('│ '),
          starter.gen_hook.aligning('center', 'center'),
        },
        footer = footer(),
      }

      starter.setup(opts)

      vim.api.nvim_create_user_command('MiniStarterToggle', function()
        if vim.o.filetype == 'starter' then
          vim.cmd('bd')
        else
          require('mini.starter').open()
        end
      end, {})
      vim.keymap.set('n', '<leader>ts', '<cmd>MiniStarterToggle<CR>')

      -- Disable folding on Starter buffer
      vim.cmd([[ autocmd FileType Starter setlocal nofoldenable ]])
    end
  }
}
