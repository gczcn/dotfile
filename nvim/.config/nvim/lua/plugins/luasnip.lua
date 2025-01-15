return {
  'L3MON4D3/LuaSnip',
  event = { 'InsertEnter', 'CmdlineEnter' },
  build = 'make install_jsregexp',
  config = function()
    local ls = require("luasnip")

    vim.keymap.set({"i"}, "<C-k>", function() ls.expand() end, {silent = true})
    vim.keymap.set({"i", "s"}, "<C-l>", function() ls.jump( 1) end, {silent = true})
    vim.keymap.set({"i", "s"}, "<C-j>", function() ls.jump(-1) end, {silent = true})

    vim.keymap.set({"i", "s"}, "<C-f>", function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, {silent = true})
  end
}
