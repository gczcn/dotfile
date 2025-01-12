return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  enabled = true,
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<M-a>",
          accept_word = false,
          accept_line = false,
          next = "<M-{>",
          prev = "<M-}>",
          dismiss = "<C-}>",
        },
      },
    })
  end
}
