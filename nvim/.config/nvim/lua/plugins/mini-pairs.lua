return {
  'echasnovski/mini.pairs',
  event = { 'InsertEnter', 'CmdlineEnter' },
  config = function()
    require('mini.pairs').setup({
      modes = { insert = true, command = true, terminal = false },
    })
  end,
}
