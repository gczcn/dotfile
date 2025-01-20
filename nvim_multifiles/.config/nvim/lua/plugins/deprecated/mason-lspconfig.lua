return {
  {
    'williamboman/mason-lspconfig.nvim',
    enabled = false,
    lazy = true,
    config = function()
      local mason = require('mason')
      local mason_lspconfig = require('mason-lspconfig')

      mason.setup()

      mason_lspconfig.setup({
        -- ensure_installed = {
        --   'clangd',
        --   'ts_ls',
        --   'html',
        --   'cssls',
        --   'tailwindcss',
        --   'svelte',
        --   'lua_ls',
        --   'graphql',
        --   'emmet_ls',
        --   'prismals',
        --   'pyright',
        --   'omnisharp',
        --   'gopls',
        -- },
      })
    end
  }
}
