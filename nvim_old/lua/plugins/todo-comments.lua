local input = function(keywords) -- keywords is string (TODO,FIX...)
  vim.ui.input({ prompt = [[TodoTelescope: cwd? [''](current dir) ['.'](current file dir)]] }, function(cwd)
    keywords = keywords == '' and nil or keywords
    if cwd ~= nil then
      cwd = cwd == '' and vim.fn.getcwd() or cwd
      cwd = cwd == '.' and vim.fn.expand('%:p:h') .. '/' or cwd

      vim.cmd('call feedkeys("\\<cmd>TodoTelescope ' .. (keywords and ('keywords=' .. keywords .. ' ') or '') .. 'cwd=' .. cwd .. '\\<CR>")')
    end
  end)
end

return {
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = { 'BufAdd', 'User FileOpened' },
    keys = {
      { ']t', function() require('todo-comments').jump_next() end, mode = 'n', desc = 'Next todo comment' },
      { '[t', function() require('todo-comments').jump_prev() end, mode = 'n', desc = 'Previous todo comment' },
      { '<leader>tt', function() input() end, mode = 'n', desc = 'TodoTelescope' },
    },
    cmd = { 'TodoLocList', 'TodoQuickFix', 'TodoTelescope', 'TodoTrouble' },
    config = function()
      require('todo-comments').setup({
        keywords = {
          BOOKMARK = { icon = ' ', color = 'hint' },
        },
      })
    end
  }
}
