return {
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    lazy = true,
    config = function()
      local mason = require('mason')
      local mason_tool_installer = require('mason-tool-installer')

      mason.setup()

      mason_tool_installer.setup({
        ensure_installed = {
          'stylua',
          'shfmt',
          'black',
        },
        auto_update = true,
        -- run_on_start = true,
      })

      vim.cmd.MasonToolsInstall()
    end
  }
}
