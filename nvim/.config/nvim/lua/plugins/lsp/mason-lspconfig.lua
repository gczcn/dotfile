return {
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = true,
    config = function()
      local mason = require('mason')
      local mason_lspconfig = require('mason-lspconfig')

      mason.setup()

      mason_lspconfig.setup({
        ensure_installed = {
          'ts_ls',
          'html',
          'cssls',
          'tailwindcss',
          'svelte',
          'lua_ls',
          'graphql',
          'emmet_ls',
          'prismals',
          'pyright',
          'omnisharp',
        },
      })
    end
  }
}
