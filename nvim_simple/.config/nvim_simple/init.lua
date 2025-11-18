-- =============================================================================
-- My Neovim Configuration (Simple Version)
-- https://github.com/gczcn/dotfile/
-- Author: Zixuan Chu <494353540@qq.com>
--
-- Dependencies:
--   Neovim >= 0.12.0
--
--   Language Servers:
--     clangd
--     typescript-language-server
--     basedpyright
--     lua-language-server
--     gopls
--     bash-language-server
--     fish-lsp
--     vscode-langservers-extracted
--     vim-language-server
--
-- Jump to any part of the configuration by searching for an uppercase tag.
-- Tags: BEGIN
-- =============================================================================

-- 'Global' variables
local api = vim.api
local keymap = vim.keymap
local opt = vim.opt
local create_autocmd = api.nvim_create_autocmd
local create_user_command = api.nvim_create_user_command

-- =============================================================================
-- Utils
-- Tags: UTILS
-- =============================================================================

_G.Utils = {}

-- Commenting
Utils.commenting = {}

-- See vim/_defaults.lua
---@return string
Utils.commenting.operator_rhs = function()
  return require('vim._comment').operator() .. '_'
end

-- Add comment on a new line
---@param key string
Utils.commenting.newline = function(key)
  vim.cmd(string.format([[noautocmd exe "norm! %s.\<esc>%sf.x"]], key, Utils.commenting.operator_rhs()))
  local line = api.nvim_get_current_line()
  local cursor_loc = api.nvim_win_get_cursor(0)
  vim.fn.feedkeys(string.sub(line, cursor_loc[2] + 1, -1):find('%S') and 'i' or 'a', 'n')
end

-- Add comment at the end of line
Utils.commenting.line_end = function()
  if api.nvim_get_current_line():find('%S') then
    local commentstring = vim.bo.commentstring
    local cursor_back = #commentstring - commentstring:find('%%s') - 1
    vim.cmd(string.format([[exe "call feedkeys('A%s%s')"]], ' ' .. commentstring:format(''), string.rep('\\<left>', cursor_back)))
  else
    Utils.commenting.newline('cc')
  end
end

-- Toggle comment line
Utils.commenting.toggle_line = function()
  local line = api.nvim_get_current_line()
  if line:find('%S') then
    vim.fn.feedkeys(Utils.commenting.operator_rhs(), 'n')
  else
    Utils.commenting.newline('cc')
  end
end

Utils.setup_markdown = function()
  keymap.set('i', ',n', '<CR>---<CR><CR>', { buffer = true }) -- dashes
  keymap.set('i', ',b', '****<left><left>', { buffer = true }) -- bold
  keymap.set('i', ',s', '~~~~<left><left>', { buffer = true }) -- strikethrough
  keymap.set('i', ',i', '**<left>', { buffer = true }) -- italic
  keymap.set('i', ',d', '``<left>', { buffer = true }) -- code
  keymap.set('i', ',c', '``````<left><left><left>', { buffer = true }) -- code block
  keymap.set('i', ',p', '![]()<left><left><left>', { buffer = true })
  keymap.set('i', ',1', '# ', { buffer = true })
  keymap.set('i', ',2', '## ', { buffer = true })
  keymap.set('i', ',3', '### ', { buffer = true })
  keymap.set('i', ',4', '#### ', { buffer = true })
  keymap.set('i', ',5', '##### ', { buffer = true })
  keymap.set('i', ',6', '###### ', { buffer = true })
end

-- =============================================================================
-- Keymaps
-- Tags: KEY, KEYS, KEYMAP, KEYMAPS
-- =============================================================================

---@type table<string, boolean>
local keymaps_opts = { noremap = true }

vim.g.mapleader = ' '

-- Movement
keymap.set({ 'n', 'v', 'o' }, 'u', 'k', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, 'e', 'j', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, 'n', 'h', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, 'i', 'l', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, 'N', '0', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, 'I', '$', keymaps_opts)

keymap.set({ 'n', 'v', 'o' }, 'j', 'n', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, 'J', 'N', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, 'h', 'e', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, 'H', 'E', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, '|', '^', keymaps_opts)

-- Actions
keymap.set({ 'n', 'v' }, 'E', 'J', keymaps_opts)
keymap.set({ 'n', 'v' }, 'l', 'u', keymaps_opts)
keymap.set({ 'n', 'v' }, 'L', 'U', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, 'k', 'i', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, 'K', 'I', keymaps_opts)
keymap.set('t', '<M-q>', '<C-\\><C-n>', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, '0', '`', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, '`', ':<C-F>a', keymaps_opts)

-- Indenting
keymap.set('v', '<', '<gv', keymaps_opts)
keymap.set('v', '>', '>gv', keymaps_opts)

-- Windows & Splits
keymap.set('n', '<leader>ww', '<C-w>w', keymaps_opts)
keymap.set('n', '<leader>wu', '<C-w>k', keymaps_opts)
keymap.set('n', '<leader>we', '<C-w>j', keymaps_opts)
keymap.set('n', '<leader>wn', '<C-w>h', keymaps_opts)
keymap.set('n', '<leader>wi', '<C-w>l', keymaps_opts)
keymap.set('n', '<leader>su', '<cmd>set nosb | split | set sb<CR>', keymaps_opts)
keymap.set('n', '<leader>se', '<cmd>set sb | split<CR>', keymaps_opts)
keymap.set('n', '<leader>sn', '<cmd>set nospr | vsplit | set spr<CR>', keymaps_opts)
keymap.set('n', '<leader>si', '<cmd>set spr | vsplit<CR>', keymaps_opts)
keymap.set('n', '<leader>sv', '<C-w>t<C-w>H', keymaps_opts)
keymap.set('n', '<leader>sh', '<C-w>t<C-w>K', keymaps_opts)
keymap.set('n', '<leader>srv', '<C-w>b<C-w>H', keymaps_opts)
keymap.set('n', '<leader>srh', '<C-w>b<C-w>K', keymaps_opts)

-- Resize
keymap.set('n', '<M-up>', '<cmd>resize +5<CR>', keymaps_opts)
keymap.set('n', '<M-down>', '<cmd>resize -5<CR>', keymaps_opts)
keymap.set('n', '<M-left>', '<cmd>vertical resize -10<CR>', keymaps_opts)
keymap.set('n', '<M-right>', '<cmd>vertical resize +10<CR>', keymaps_opts)

-- Commenting
keymap.set('n', 'gcO', function() Utils.commenting.newline('O') end, { desc = 'Add comment on the line above', silent = true })
keymap.set('n', 'gco', function() Utils.commenting.newline('o') end, { desc = 'Add comment on the line below', silent = true })
keymap.set('n', 'gca', function() Utils.commenting.line_end() end, { desc = 'Add comment at the end of line', silent = true })
keymap.set('n', 'gcc', function() Utils.commenting.toggle_line() end, { desc = 'Toggle comment line', silent = true })

-- Copy and Paste
keymap.set({ 'n', 'v' }, '<M-y>', '"+y', keymaps_opts)
keymap.set({ 'n', 'v' }, '<M-Y>', '"+Y', keymaps_opts)
keymap.set({ 'n', 'v' }, '<M-p>', '"+p', keymaps_opts)
keymap.set({ 'n', 'v' }, '<M-P>', '"+P', keymaps_opts)
keymap.set({ 'n', 'v' }, '<M-d>', '"+d', keymaps_opts)
keymap.set({ 'n', 'v' }, '<M-D>', '"+D', keymaps_opts)
keymap.set('o', '<M-y>', 'y', keymaps_opts)
keymap.set('o', '<M-Y>', 'Y', keymaps_opts)
keymap.set('o', '<M-d>', 'd', keymaps_opts)
keymap.set('o', '<M-D>', 'D', keymaps_opts)

-- Buffer
keymap.set('n', '<leader>bd', '<cmd>bd<CR>', keymaps_opts)

-- Other
keymap.set({ 'n', 'v' }, '<F5>', function() opt.background = vim.o.background == 'dark' and 'light' or 'dark' end, keymaps_opts)
keymap.set('n', '<leader>tc', function() opt.cursorcolumn = not vim.o.cursorcolumn end, keymaps_opts)
keymap.set('n', '<leader>l', '<cmd>noh<CR>', keymaps_opts)
keymap.set('n', '<leader>fn', '<cmd>messages<CR>', keymaps_opts)
keymap.set('n', '<leader>oo', '<cmd>e ' .. vim.fn.stdpath('config') .. '/init.lua<CR>')
keymap.set('n', 'gX', function() vim.ui.open('https://github.com/' .. vim.fn.expand('<cfile>')) end)
keymap.set('n', '<leader><leader>', '<cmd>lua vim.diagnostic.config({virtual_lines=not vim.diagnostic.config().virtual_lines})<CR>')

-- =============================================================================
-- Language Server Protocol Configuration
-- Because these language servers has no configurations, you need to install the
-- nvim-lspconfig plugin. See the LSPCONFIG part
-- Tags: LSP
-- =============================================================================

vim.lsp.enable('html')
vim.lsp.enable('ts_ls')
vim.lsp.enable('cssls')
vim.lsp.enable('basedpyright')
vim.lsp.enable('lua_ls')
vim.lsp.enable('gopls')
vim.lsp.enable('bashls')
vim.lsp.enable('fish_lsp')
vim.lsp.enable('vimls')
vim.lsp.enable('clangd')

-- Keymaps
-- Default_keymaps:
--   grn:   rename
--   gra:   code action
--   grr:   references
--   gri:   implementation
--   grt:   type_definition
--   * an:    vim.lsp.buf.selection_range(vim.v.count1)
--   * in:    vim.lsp.buf.selection_range(-vim.v.count1)
--   g0:    document symbol
--   <C-S>: signature help

keymap.del('x', 'in')
keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration' })
keymap.set({ 'n', 'v' }, '<leader>cc', vim.lsp.codelens.run, { desc = 'Run Codelens' })
keymap.set('n', '<leader>cC', vim.lsp.codelens.refresh, { desc = 'Refresh & Display Codelens' })
keymap.set('n', 'grf', vim.diagnostic.open_float, { desc = 'Show Line Diagnostics' })
keymap.set('n', '<M-[>', function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = 'Goto Prev Diagnostic' })
keymap.set('n', '<M-]>', function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = 'Goto Next Diagnostic' })
keymap.set('n', 'U', vim.lsp.buf.hover, { desc = 'Show documentation for what is under cursor' })
keymap.set('n', '<leader>rs', '<cmd>LspRestart<CR>', { desc = 'Restart LSP' })
keymap.set('n', '<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, { desc = 'Toggle Inlay Hint' })
keymap.set('x', 'kn', function() vim.lsp.buf.selection_range(-vim.v.count1) end, keymaps_opts)

-- Diagnostic Config
vim.diagnostic.config({
  virtual_text = {
    prefix = '#',
    current_line = true,
  },
  virtual_lines = false, -- press <leader><leader> to toggle this option.
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.HINT] = '',
      [vim.diagnostic.severity.INFO] = '',
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticWarn',
      [vim.diagnostic.severity.HINT] = 'DiagnosticHint',
      [vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
    },
  },
})

-- =============================================================================
-- Options
-- Tags: OPTS, OPTIONS
-- =============================================================================

vim.g.encoding = 'UTF-8'

opt.autowrite = true
opt.breakindent = true -- Wrap indent to match line start
-- opt.colorcolumn = '80' -- Line number reminder
opt.conceallevel = 2 -- Hide * markup for hold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.copyindent = true -- Copy the previous indentation on autoindenting
opt.cursorline = true -- Highlight the text line of the cursor
opt.expandtab = true
opt.fileencoding = 'utf-8' -- File content encoding for the buffer
opt.foldcolumn = '0'
opt.guicursor = vim.fn.has('nvim-0.11') == 1
  and 'n-v-sm:block,i-c-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor'
  or 'n-v-sm:block,i-c-ci-ve:ver25,r-cr-o:hor20'
opt.ignorecase = true -- Ignore case
opt.laststatus = 2
opt.list = true -- Show some hidden characters
opt.listchars = { tab = '> ', trail = '-', extends = '>', precedes = '<', nbsp = '+' }
opt.maxmempattern = 5000
opt.number = true
opt.pumblend = 10
opt.pumheight = 30
opt.scrolloff = 8 -- Lines of context
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Number of space inserted for indentation
opt.showmode = false -- No display mode
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = 'auto'
opt.smartcase = true -- Case sensitive searching
opt.smartindent = true -- Insert indents automatically
opt.smoothscroll = true
opt.softtabstop = 2
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- Enable true colors
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.winblend = 10
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

-- =============================================================================
-- Commands and Aliases
-- Tags: COMMANDS
-- =============================================================================

vim.cmd.cabbrev('W! w!')
vim.cmd.cabbrev('W1 w!')
vim.cmd.cabbrev('w1 w!')
vim.cmd.cabbrev('Q! q!')
vim.cmd.cabbrev('Q1 q!')
vim.cmd.cabbrev('q1 q!')
vim.cmd.cabbrev('qa1 qa!')
vim.cmd.cabbrev('Qa! qa!')
vim.cmd.cabbrev('Qa1 qa!')
vim.cmd.cabbrev('QA! qa!')
vim.cmd.cabbrev('QA1 qa!')
vim.cmd.cabbrev('Qall! qall!')
vim.cmd.cabbrev('Wa wa')
vim.cmd.cabbrev('Wq wq')
vim.cmd.cabbrev('wQ wq')
vim.cmd.cabbrev('WQ wq')
vim.cmd.cabbrev('wq1 wq!')
vim.cmd.cabbrev('Wq1 wq!')
vim.cmd.cabbrev('wQ1 wq!')
vim.cmd.cabbrev('WQ1 wq!')
vim.cmd.cabbrev('Wqa wqa')
vim.cmd.cabbrev('WQa wqa')
vim.cmd.cabbrev('WQA wqa')
vim.cmd.cabbrev('wqa1 wqa!')
vim.cmd.cabbrev('Wqa1 wqa!')
vim.cmd.cabbrev('WQa1 wqa!')
vim.cmd.cabbrev('WQA1 wqa!')
vim.cmd.cabbrev('W w')
vim.cmd.cabbrev('Q q')
vim.cmd.cabbrev('Qa qa')
vim.cmd.cabbrev('Qall qall')

-- =============================================================================
-- Autocmds
-- Tags: AU, AUTOCMD, AUTOCMDS
-- =============================================================================

-- Line breaks are not automatically commented
create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    vim.cmd('setlocal formatoptions-=c formatoptions-=r formatoptions-=o')
  end,
})

-- Highlight when copying
---@diagnostic disable-next-line: param-type-mismatch
create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.highlight.on_yank()
  end,
})

create_autocmd('FileType', {
  pattern = { 'kotlin', 'java' },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.smarttab = true
    vim.opt_local.expandtab = true
  end,
})

create_autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.opt_local.commentstring = '/* %s */'
  end,
})

create_autocmd('FileType', {
  pattern = { 'json', 'json5', 'jsonc', 'lsonc', 'markdown' },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

create_autocmd('FileType', {
  pattern = { 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    Utils.setup_markdown()
  end,
})

-- =============================================================================
-- Plugin Installation
-- Tags: PLUGIN_INSTALLATION, PI
-- =============================================================================
vim.pack.add({
  'https://github.com/ellisonleao/gruvbox.nvim',
  'https://github.com/folke/ts-comments.nvim',
  'https://github.com/gczcn/antonym.nvim',
  'https://github.com/neovim/nvim-lspconfig',
})

-- =============================================================================
-- Plugin Configurations
-- Tags: PLUGIN_CONFIGURATIONS, PC
-- =============================================================================

-- =============== GRUVBOX ===============
create_autocmd('ColorScheme', {
  group = api.nvim_create_augroup('custom_highlights_gruvbox', {}),
  pattern = 'gruvbox',
  callback = function()
    local set_hl = vim.api.nvim_set_hl
    local palette = require('gruvbox').palette

    set_hl(0, 'CursorLineNr', {
      fg = vim.o.background == 'dark' and palette.bright_orange or palette.faded_orange,
      bg = vim.o.background == 'dark' and palette.dark1 or palette.light1,
    })
  end,
})

require('gruvbox').setup({
  italic = {
    strings = false,
    emphasis = false,
    comments = false,
    operators = false,
    folds = false,
  },
})

vim.cmd.colorscheme('gruvbox')

-- =============== TS_COMMENTS ===============
require('ts-comments').setup({
  lang = {
    c = {
      '/* %s */',
      '// %s',
    },
  },
})

-- =============== ANTONYM ===============
require('antonym').setup()
keymap.set('n', '<leader>ta', '<cmd>AntonymWord<CR>')

-- =============== LSPCONFIG ===============
vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      typeCheckingMode = 'standard',
    },
  },
})

-- configure lua server (with special settings)
vim.lsp.config('lua_ls', {
  settings = { -- custom settings for lua
    Lua = {
      -- make the language server recognize 'vim' global
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        -- make language server aware of runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.stdpath('config') .. '/lua'] = true,
        },
      },
      hint = {
        enable = true,
      },
    },
  },
})

-- configure Go language server
vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_dir = require('lspconfig.util').root_pattern('go.work', 'go.mod', '.git'),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
    },
  },
})

-- configure Bash language server
vim.lsp.config('bashls', {
  cmd = { 'bash-language-server', 'start' },
})

-- configure C and C++ ... language server
vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--background-index',
  }
})
