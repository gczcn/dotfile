return {
  'nivm-treesitter/nvim-treesitter',
  event = { 'User FileOpened', 'BufAdd' },
  cmd = {
    'TSBufDisable',
    'TSBufEnable',
    'TSBufToggle',
    'TSDisable',
    'TSEnable',
    'TSToggle',
    'TSInstall',
    'TSInstallInfo',
    'TSInstallSync',
    'TSModuleInfo',
    'TSUninstall',
    'TSUpdate',
    'TSUpdateSync',
  },
  keys = {
    ':',
    '/',
    '?',
  },
  build = ':TSUpdate',
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'lua',
        'luadoc',
        'luap',
        'python',
        'c',
        'html',
        'vim',
        'vimdoc',
        'javascript',
        'typescript',
        'bash',
        'diff',
        'jsdoc',
        'json',
        'jsonc',
        'toml',
        'yaml',
        'tsx',
        'markdown',
        'markdown_inline',
        'regex',
        'c_sharp',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<CR>',
          node_decremental = '<BS>',
          -- scope_incremental = '<TAB>',
        },
      },
    })
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.wo.foldlevel = 90
  end
}
