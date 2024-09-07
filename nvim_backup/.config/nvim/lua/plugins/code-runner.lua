vim.g.code_runner_run_args = ''
local setup = function()
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
      python = 'python3 $file ' .. vim.g.code_runner_run_args,
      lua = 'lua $file ' .. vim.g.code_runner_run_args,
      typescript = 'deno run',
      rust = {
        'cd $dir &&',
        'rustc $fileName &&',
        '$dir/$fileNameWithoutExt'
      },
    },
  })
end

return {
  'CRAG666/code_runner.nvim',
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
      vim.ui.input({prompt = 'Input Args:'}, function (args)
        if args ~= nil then
          vim.g.code_runner_run_args = args
          setup()
        end
      end)
    end },
    { '<leader>r', '<cmd>RunCode<CR>' },
    { '<leader>rr', '<cmd>RunCode<CR>' },
    { '<leader>R', '<cmd>RunCode<CR>' },
    { '<leader>rf', '<cmd>RunFile<CR>' },
    { '<leader>rft', '<cmd>RunFile tab<CR>' },
    { '<leader>rp', '<cmd>RunProject<CR>' },
    { '<leader>rc', '<cmd>RunClose<CR>' },
    { '<leader>crf', '<cmd>CRFiletype<CR>' },
    { '<leader>crp', '<cmd>CRProjects<CR>' },
  },
  config = function()
    setup()
  end
}
