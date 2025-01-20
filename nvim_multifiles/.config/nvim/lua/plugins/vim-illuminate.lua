return {
  'rrethy/vim-illuminate',
  event = 'User FileOpened',
  opts = {
    delay = 0,
    filetypes_denylist = {
      'dirbuf',
      'dirvish',
      'fugitive',
      'starter',
      'telescopeprompt',
    },
  },
  config = function(_, opts)
    require('illuminate').configure(opts)

    local function map(key, dir, buffer)
      vim.keymap.set('n', key, function()
        require('illuminate')['goto_' .. dir .. '_reference'](false)
      end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' reference', buffer = buffer })
    end

    map(']]', 'next')
    map('[[', 'prev')

    -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
    vim.api.nvim_create_autocmd('FileType', {
      pattern = '*',
      callback = function()
        local buffer = vim.api.nvim_get_current_buf()
        map(']]', 'next', buffer)
        map('[[', 'prev', buffer)
      end,
    })

    vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
      pattern = '*',
      callback = function()
        require('illuminate').resume()
      end,
    })

    vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
      pattern = '*',
      callback = function()
        require('illuminate').pause()
      end,
    })
  end,
  keys = {
    { ']]', desc = 'next reference' },
    { '[[', desc = 'prev reference' },
  },
}
