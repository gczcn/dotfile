return {
  'echasnovski/mini.starter', config = function()
    local starter = require('mini.starter')
    local v = vim.version()
    local prerelease = v.api_prerelease and '(Pre-release) v' or 'v'

    local version = function()
      return 'NVIM ' .. prerelease .. tostring(vim.version())
    end

    local header = function()
      return version() .. '\n\n' ..
        'Nvim is open source and freely distributable\n' ..
        'https://neovim.io/#chat'

        -- 'This configuration\n' ..
        -- 'https://github.com/gczcn/dotfile/tree/main/nvim/.config/nvim'
    end

    local footer = function()
      return
        os.date()
    end

    local recent_files = function(n, index_h, index, current_dir, show_path)
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
        local i = index or ''
        local items = {}
        for _, f in ipairs(vim.list_slice(files, 1, n)) do
          local name = index_h .. (i ~= '' and (i ~= 10 and i .. ' ' or '0 ') or '') .. vim.fn.fnamemodify(f, ':t') .. show_path(f)
          i = i == '' and '' or i + 1
          table.insert(items, { action = 'edit ' .. f, name = name, section = section })
        end

        return items
      end
    end

    local opts = {
      evaluate_single = true,
      items = {
        -- Recent files (Current directory)
        recent_files(5, '', 1, vim.fn.getcwd()),

        -- Recent files
        recent_files(5, '`', 1),

        -- Builtin actions
        { name = 'n New buffer', action = ':ene', section = 'Builtin actions' },
        { name = 'q Quit Neovim', action = ':q', section = 'Builtin actions' },

        -- Plugins actions
        { name = 's Sync Plugins', action = ':Lazy sync', section = 'Plugins actions' },
        { name = 'p Plugins', action = ':Lazy', section = 'Plugins actions' },
        -- { name = 'Mason', action = ':Mason', section = 'Plugins actions' },

        -- Oil
        { name = 'e File Browser', action = ':Oil', section = 'Oil' },
        { name = 'w File Browser (Options)', action = ':Oil ' .. vim.fn.stdpath('config'), section = 'Oil' },

        -- FzfLua
        { name = 'f Find files', action = ':FzfLua files', section = 'FzfLua' },
        { name = 'l Live grep', action = ':FzfLua live_grep', section = 'FzfLua' },
        { name = 'g Grep', action = ':FzfLua grep', section = 'FzfLua' },
        { name = 'h Help tags', action = ':FzfLua helptags', section = 'FzfLua' },
        { name = 'r Recent files', action = ':FzfLua oldfiles', section = 'FzfLua' },
        -- { name = 'Bookmarks', action = ':Telescope bookmarks list', section = 'Telescope' },
        { name = 'o Options', action = string.format(':FzfLua files cwd=%s', vim.fn.stdpath('config')), section = 'FzfLua' },
      },
      -- items = nil,
      content_hooks = {
        starter.gen_hook.padding(7, 3),
        -- starter.gen_hook.adding_bullet('│ '),
        starter.gen_hook.adding_bullet('░ '),
      },
      header = header(),
      footer = footer(),
      -- footer = '',
      query_updaters = 'abcdefghijklmnopqrstuvwxyz0123456789_-.`',
      silent = true,

    }

    starter.setup(opts)

    vim.api.nvim_create_user_command('MiniStarterToggle', function()
      if vim.o.filetype == 'ministarter' then
        require('mini.starter').close()
      else
        require('mini.starter').open()
      end
    end, {})

    vim.keymap.set('n', '<leader>ts', '<cmd>MiniStarterToggle<CR>')

    vim.api.nvim_create_autocmd('User', {
      pattern = 'LazyVimStarted',
      callback = function()
        local stats = require('lazy').stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

        local get_startuptime = function()
          return 'loaded '
            .. stats.loaded
            .. '/'
            .. stats.count
            .. ' plugins in '
            .. ms
            .. 'ms'
        end

        local ft = function()
          -- stylua: ignore
          return
          get_startuptime() .. '\n' ..
          footer()
        end

        starter.config.footer = ft

        if vim.o.filetype == 'ministarter' then
          starter.refresh()
        end
      end
    })

    -- Disable folding on Starter buffer
    vim.cmd([[ autocmd FileType Starter setlocal nofoldenable ]])
  end
}
