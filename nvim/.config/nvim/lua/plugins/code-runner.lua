vim.g.code_runner_run_args = ''

return {
  'CRAG666/code_runner.nvim',
  dependencies = {
    'iamcco/markdown-preview.nvim',
  },
  cmd = {
    'RunCode',
    'RunFile',
    'RunProject',
    'RunClose',
    'CRFiletype',
    'CRProjects',
  },
  keys = {
    { '<leader>ra', function()
      vim.ui.input({prompt = 'Input Args: '}, function (args)
        if args ~= nil then
          vim.g.code_runner_run_args = args
        end
      end)
    end },
    { '<leader>R', function()
      vim.ui.input({prompt = 'Input Args: '}, function (args)
        if args ~= nil then
          vim.g.code_runner_run_args = args
          vim.cmd.RunCode()
        end
      end)
    end },
    { '<leader>r', '<cmd>RunCode<CR>' },
    { '<leader>rr', '<cmd>RunCode<CR>' },
    { '<leader>rf', '<cmd>RunFile<CR>' },
    { '<leader>rft', '<cmd>RunFile tab<CR>' },
    { '<leader>rp', '<cmd>RunProject<CR>' },
    { '<leader>rc', '<cmd>RunClose<CR>' },
    { '<leader>crf', '<cmd>CRFiletype<CR>' },
    { '<leader>crp', '<cmd>CRProjects<CR>' },
  },
  config = function()
    require('code_runner').setup({
      term = {
        size = 20
      },
      filetype = {
        markdown = function ()
          vim.cmd [[MarkdownPreviewToggle]]
        end,
        java = {
          'cd $dir &&',
          'javac $fileName &&',
          'java $fileNameWithoutExt'
        },
        python = function() return 'python3 $file ' .. vim.g.code_runner_run_args end,
        lua = function() return 'lua $file ' .. vim.g.code_runner_run_args end,
        typescript = 'deno run',
        rust = {
          'cd $dir &&',
          'rustc $fileName &&',
          '$dir/$fileNameWithoutExt'
        },
        c = function(...)
          local c_base = {
            'cd $dir &&',
            'gcc-14 --std=gnu23 $fileName -o', -- for homebrew
            -- 'gcc $fileName -o',
            -- 'clang $fileName -o',
            '/tmp/$fileNameWithoutExt',
          }
          local c_exec = {
            '&& /tmp/$fileNameWithoutExt &&',
            'rm /tmp/$fileNameWithoutExt',
          }
          vim.ui.input({ prompt = 'Add more args: ' }, function(input)
            c_base[4] = input
            vim.print(vim.tbl_extend('force', c_base, c_exec))
            require('code_runner.commands').run_from_fn(vim.list_extend(c_base, c_exec))
          end)
        end,
      },
    })
  end
}
