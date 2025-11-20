-- ===================
-- Lsp Configuration
-- See :h lsp-config
-- ===================

local virtual_text_prefix = '\\'
local current_line = true
local lsp = vim.lsp
local api = vim.api

-- Enable configured language servers
-- You can find server configurations from lua/*.lua files
lsp.enable('html')
lsp.enable('cssls')
lsp.enable('jsonls')
lsp.enable('basedpyright')
lsp.enable('lua_ls')
lsp.enable('gopls')
lsp.enable('bashls')
lsp.enable('fish_lsp')
lsp.enable('vimls')
lsp.enable('clangd')

-- Diagnostic Config
vim.diagnostic.config({
  virtual_text = {
    prefix = virtual_text_prefix,
    current_line = current_line,
  },
  virtual_lines = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.HINT] = '',
      [vim.diagnostic.severity.INFO] = '',
    },

    -- The following highlight groups need to be set manually
    numhl = {
      -- [vim.diagnostic.severity.ERROR] = 'DiagnosticNumHlError',
      -- [vim.diagnostic.severity.WARN] = 'DiagnosticNumHlWarn',
      -- [vim.diagnostic.severity.HINT] = 'DiagnosticNumHlHint',
      -- [vim.diagnostic.severity.INFO] = 'DiagnosticNumHlInfo',
      [vim.diagnostic.severity.ERROR] = 'DiagnosticError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticWarn',
      [vim.diagnostic.severity.HINT] = 'DiagnosticHint',
      [vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
    },
  },
})

-- Enable LSP Completion
local augroup = api.nvim_create_augroup('auto_completion', {})

api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client ~= nil and client:supports_method('textDocument/completion') then
      lsp.completion.enable(true, client.id, ev.buf, {})
    end
  end,
})

-- Keymaps
-- Keymaps defined by Neovim runtimes (not sure):
--   grn:   rename
--   gra:   code action
--   grr:   references
--   gri:   implementation
--   grt:   type_definition
--   an:    vim.lsp.buf.selection_range(vim.v.count1)
--   in:    vim.lsp.buf.selection_range(-vim.v.count1)
--   g0:    document symbol
--   <C-S>: signature help

local keyset = vim.keymap.set
local keydel = vim.keymap.del

-- Completion
keyset('i', '<M-space>', vim.lsp.completion.get)
keyset(
  'i',
  '<Tab>',
  'pumvisible() ? "\\<C-n>" : "\\<Tab>"',
  { expr = true, noremap = true }
)
keyset(
  'i',
  '<S-Tab>',
  'pumvisible() ? "\\<C-p>" : "\\<S-Tab>"',
  { expr = true, noremap = true }
)

-- Toggle virtual text style
keyset('n', 'grl', function()
  if vim.diagnostic.config().virtual_lines then
    vim.diagnostic.config({
      virtual_text = {
        prefix = virtual_text_prefix,
        current_line = current_line,
      },
      virtual_lines = false,
    })
  else
    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = {
        current_line = current_line,
      },
    })
  end
end, { desc = 'Toggle diagnostic virtual text style' })

if vim.fn.has('nvim-0.12.0') == 1 then
  keydel('x', 'in')
end

keyset('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
keyset('n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration' })

keyset(
  { 'n', 'v' },
  '<leader>cc',
  vim.lsp.codelens.run,
  { desc = 'Run Codelens' }
)
keyset(
  'n',
  '<leader>cC',
  vim.lsp.codelens.refresh,
  { desc = 'Refresh & Display Codelens' }
)

keyset(
  'n',
  'grf',
  vim.diagnostic.open_float,
  { desc = 'Show Line Diagnostics' }
)
keyset('n', 'grF', function()
  vim.diagnostic.open_float()
  vim.diagnostic.open_float()
end, { desc = 'Show Line Diagnostics (focus on the floating window)' })

keyset('n', 'grc', function()
  vim.diagnostic.open_float({ scope = 'cursor' })
end, { desc = 'Show Cursor Diagnostics' })
keyset('n', 'grC', function()
  vim.diagnostic.open_float({ scope = 'cursor' })
  vim.diagnostic.open_float({ scope = 'cursor' })
end, { desc = 'Show Cursor Diagnostics (focus on the floating window)' })

keyset('n', '<M-[>', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Goto Prev Diagnostic' })
keyset('n', '<M-]>', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Goto Next Diagnostic' })

keyset(
  'n',
  'U',
  vim.lsp.buf.hover,
  { desc = 'Show documentation for what is under cursor' }
)

keyset('n', '<leader>rs', '<cmd>LspRestart<CR>', { desc = 'Restart LSP' })
keyset('n', '<leader>th', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = 'Toggle Inlay Hint' })
keyset('x', 'kn', function()
  vim.lsp.buf.selection_range(-vim.v.count1)
end)
