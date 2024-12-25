return {
  {
    'williamboman/mason.nvim',
    cmd = {
      'Mason',
      'MasonInstall',
      'MasonLog',
      'MasonUninstall',
      'MasonUninstallAll',
      'MasonUpdate',
    },
    build = ':MasonUpdate',
    config = function()
      require('mason').setup({
        ui = {
          icons = {
            package_installed = '󰽢',
            package_pending = '',
            package_uninstalled = '󰽤',
          },
        },
      })
    end
  }
}
