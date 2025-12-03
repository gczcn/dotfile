-- =============================================================================
-- My Neovim Configuration (Single File Version)
-- https://github.com/gczcn/dotfile/
-- Author: Zixuan Chu <494353540@qq.com>
--
-- Dependencies:
--   Neovim >= 0.11 (Nightly version is recommended)
--   tree-sitter-cli - for nvim-treesitter
--   a C compiler such as gcc, msvk(cl.exe) - for nvim-treesitter
--   curl - for nvim-treesitter
--   tar - for nvim-treesitter
--   make - for luasnip
--
-- Optional Dependencies:
--   ripgrep
--   fd
--   Nerd Font - if you want to show some icons
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
--   Debuggers:
--     delve (go)
--
--   Formatters:
--     black
--     stylua
--     shfmt
--
-- The best way to install these dependencies is to use your distribution's package manager,
--
-- Jump to any part of the configuration by searching for an uppercase tag.
--
-- I hope I can read the code later :)
-- =============================================================================
-- TODO: Remove more useless plugins
-- TODO: main branch of nvim-treesitter and nvim-treesitter-textobjects. (doing)

-- =============================================================================
-- Globar vars
-- Tags: VAR, VARS, GLOBAL
-- =============================================================================

local api = vim.api
local keymap = vim.keymap
local opt = vim.opt
local create_autocmd = api.nvim_create_autocmd
local create_augroup = api.nvim_create_augroup
local create_user_command = api.nvim_create_user_command

---@class global_config
---@field enabled_plugins boolean
---@field enabled_copilot boolean
---@field enabled_custom_statusline boolean
---@field border string[]
local global_config = {
  enabled_plugins = true,
  enabled_copilot = false,
  enabled_custom_statusline = false,
  border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
}

-- =============================================================================
-- Utils
-- Tags: UTIL, UTILS
-- =============================================================================

_G.Utils = {}

-- Access GitHub using username/reponame like gczcn/dotfile
---@param s string|nil
Utils.goto_github = function(s)
  vim.ui.open('https://github.com/' .. s)
end

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
    vim.cmd(
      string.format(
        [[exe "call feedkeys('A%s%s')"]],
        ' ' .. commentstring:format(''),
        string.rep('\\<left>', cursor_back)
      )
    )
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

-- Copy from https://github.com/LazyVim/LazyVim/blob/f11890bf99477898f9c003502397786026ba4287/lua/lazyvim/util/ui.lua#L171-L187
---@param name string
---@param bg boolean?
---@return string|nil
Utils.get_hl = function(name, bg)
  ---@type {foreground?:number}?
  local hl = api.nvim_get_hl and api.nvim_get_hl(0, { name = name, link = false })
    ---@diagnostic disable-next-line: deprecated
    or api.nvim_get_hl_by_name(name, true)
  ---@diagnostic disable-next-line: undefined-field
  ---@type string?
  local color = nil
  if hl then
    if bg then
      ---@diagnostic disable-next-line: undefined-field
      color = hl.bg or hl.background
    else
      ---@diagnostic disable-next-line: undefined-field, cast-local-type
      color = hl.fg or hl.foreground
    end
  end
  return color and string.format('#%06x', color) or nil
end

-- https://www.reddit.com/r/neovim/comments/1egmpag/comment/lg2epw8/
---@param plugin_name string
---@param plugin_open function
Utils.autocmd_attach_file_browser = function(plugin_name, plugin_open)
  local previous_buffer_name
  create_autocmd('BufEnter', {
    desc = string.format('[%s] replacement for Netrw', plugin_name),
    pattern = '*',
    callback = function()
      vim.schedule(function()
        local buffer_name = api.nvim_buf_get_name(0)
        if vim.fn.isdirectory(buffer_name) == 0 then
          _, previous_buffer_name = pcall(vim.fn.expand, '#:p:h')
          return
        end

        -- Avoid reopening when exiting without selecting a file
        if previous_buffer_name == buffer_name then
          previous_buffer_name = nil
          return
        else
          previous_buffer_name = buffer_name
        end

        -- Ensure no buffers remain with the directory name
        api.nvim_set_option_value('bufhidden', 'wipe', { buf = 0 })
        plugin_open(vim.fn.expand('%:p:h'))
      end)
    end,
  })
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
keymap.set('n', 'gcO', function()
  Utils.commenting.newline('O')
end, { desc = 'Add comment on the line above', silent = true })
keymap.set('n', 'gco', function()
  Utils.commenting.newline('o')
end, { desc = 'Add comment on the line below', silent = true })
keymap.set('n', 'gcA', function()
  Utils.commenting.line_end()
end, { desc = 'Add comment at the end of line', silent = true })
keymap.set('n', 'gcc', function()
  Utils.commenting.toggle_line()
end, { desc = 'Toggle comment line', silent = true })

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
keymap.set({ 'n', 'v' }, '<F5>', function()
  opt.background = vim.o.background == 'dark' and 'light' or 'dark'
end, keymaps_opts)
keymap.set('n', '<leader>tc', function()
  opt.cursorcolumn = not vim.o.cursorcolumn
end, keymaps_opts)
keymap.set('n', '<leader>l', '<cmd>noh<CR>', keymaps_opts)
keymap.set('n', '<leader>fn', '<cmd>messages<CR>', keymaps_opts)
keymap.set('n', '<leader>oo', '<cmd>e ' .. vim.fn.stdpath('config') .. '/init.lua<CR>')
keymap.set('n', 'gX', function()
  Utils.goto_github(vim.fn.expand('<cfile>'))
end)

-- =============================================================================
-- Language Server Configuration
-- Because these language servers has no configurations, you need to install the
-- nvim-lspconfig plugin.
-- Tags: LSPC, LSC
-- =============================================================================

-- Enable language servers
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

-- Diagnostic Config
vim.diagnostic.config({
  virtual_text = true,
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
      [vim.diagnostic.severity.ERROR] = 'DiagnosticNumHlError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticNumHlWarn',
      [vim.diagnostic.severity.HINT] = 'DiagnosticNumHlHint',
      [vim.diagnostic.severity.INFO] = 'DiagnosticNumHlInfo',
    },
  },
})

-- Keymaps
-- Default_keymaps:
--   grn:   rename
--   gra:   code action
--   grr:   references
--   gri:   implementation
--   grt:   type_definition
--   an:    vim.lsp.buf.selection_range(vim.v.count1)
--   in:    vim.lsp.buf.selection_range(-vim.v.count1)
--   g0:    document symbol
--   <C-S>: signature help

if vim.fn.has('nvim-0.12.0') == 1 then
  keymap.del('x', 'in')
end

keymap.set('n', 'grl', function()
  if vim.diagnostic.config().virtual_lines then
    vim.diagnostic.config({
      virtual_text = true,
      virtual_lines = false,
    })
  else
    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = true,
    })
  end
end, { desc = 'Toggle diagnostic virtual text style' })

keymap.set('n', 'grf', function()
  vim.diagnostic.open_float()
end, { desc = 'Show Line Diagnostics' })
keymap.set('n', 'grF', function()
  vim.diagnostic.open_float()
  vim.diagnostic.open_float()
end, { desc = 'Show Line Diagnostics (focus on the floating window)' })

keymap.set('n', 'grc', function()
  vim.diagnostic.open_float({ scope = 'cursor' })
end, { desc = 'Show Cursor Diagnostics' })
keymap.set('n', 'grC', function()
  vim.diagnostic.open_float({ scope = 'cursor' })
  vim.diagnostic.open_float({ scope = 'cursor' })
end, { desc = 'Show Cursor Diagnostics (focus on the floating window)' })

keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration' })

keymap.set({ 'n', 'v' }, '<leader>cc', vim.lsp.codelens.run, { desc = 'Run Codelens' })
keymap.set('n', '<leader>cC', vim.lsp.codelens.refresh, { desc = 'Refresh & Display Codelens' })

keymap.set('n', '<M-[>', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Goto Prev Diagnostic' })
keymap.set('n', '<M-]>', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Goto Next Diagnostic' })

keymap.set('n', 'U', vim.lsp.buf.hover, { desc = 'Show documentation for what is under cursor' })

keymap.set('n', '<leader>rs', '<cmd>LspRestart<CR>', { desc = 'Restart LSP' })
keymap.set('n', '<leader>th', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = 'Toggle Inlay Hint' })
keymap.set('x', 'kn', function()
  vim.lsp.buf.selection_range(-vim.v.count1)
end, keymaps_opts)

-- =============================================================================
-- Options
-- Tags: OPT, OPTS, OPTION, OPTIONS
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
-- opt.fillchars = { foldsep = ' ', eob = ' ' }
opt.fillchars = { foldsep = ' ' }
opt.foldcolumn = '0'
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.grepformat = '%f:%l:%c:%m'
opt.grepprg = 'rg --vimgrep'
opt.guicursor = vim.fn.has('nvim-0.11') == 1
    and 'n-v-sm:block,i-c-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor'
  or 'n-v-sm:block,i-c-ci-ve:ver25,r-cr-o:hor20'
opt.ignorecase = true -- Ignore case
-- opt.laststatus = 2
opt.list = true -- Show some hidden characters
opt.listchars = { tab = '> ', trail = '-', extends = '>', precedes = '<', nbsp = '+' }
opt.maxmempattern = 5000
opt.number = true
-- opt.pumblend = 10
opt.pumheight = 30
opt.scrolloff = 8 -- Lines of context
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Number of space inserted for indentation
opt.shortmess = vim.o.shortmess .. 'I' -- Don't give the intro messages when starting Neovim
opt.showmode = false -- No display mode
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = 'yes'
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
-- opt.winblend = 10
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

-- =============================================================================
-- Custom StatusLine
-- Dependencies: gitsigns.nvim plugin
-- Highlights:
--   CustomStatusLineModeNull
--   CustomStatusLineModeNormal
--   CustomStatusLineModeVisual
--   CustomStatusLineModeSelect
--   CustomStatusLineModeInsert
--   CustomStatusLineModeReplace
--   CustomStatusLineModeCommand
--   CustomStatusLineModePrompt
--   CustomStatusLineModeTerminal
--   CustomStatusLineFileInfo
--   CustomStatusLineGitHead
--   CustomStatusLineGitAdded
--   CustomStatusLineGitChanged
--   CustomStatusLineGitRemoved
--   CustomStatusLineDiagnosticError
--   CustomStatusLineDiagnosticWarn
--   CustomStatusLineDiagnosticHint
--   CustomStatusLineDiagnosticInfo
-- Tags: STATUSLINE
-- =============================================================================

-- ---------- StatusLine ----------
---@return string
_G.GetStatusLine = function()
  local mode_map = {
    ['n'] = 'NOR',
    ['no'] = 'O-P',
    ['nov'] = 'O-P',
    ['noV'] = 'O-P',
    ['no\22'] = 'O-P',
    ['niI'] = 'N-I',
    ['niR'] = 'N-R',
    ['niV'] = 'N',
    ['nt'] = 'N-T',
    ['v'] = 'VIS',
    ['vs'] = 'V',
    ['V'] = 'V-L',
    ['Vs'] = 'V-L',
    ['\22'] = 'V-B',
    ['\22s'] = 'V-B',
    ['s'] = 'S',
    ['S'] = 'S-L',
    ['\19'] = 'S-B',
    ['i'] = 'INS',
    ['ic'] = 'I-C',
    ['ix'] = 'I-X',
    ['R'] = 'REP',
    ['Rc'] = 'R-C',
    ['Rx'] = 'R-X',
    ['Rv'] = 'V-R',
    ['Rvc'] = 'RVC',
    ['Rvx'] = 'RVX',
    ['c'] = 'CMD',
    ['cv'] = 'EX',
    ['ce'] = 'EX',
    ['r'] = 'R',
    ['rm'] = 'M',
    ['r?'] = 'C',
    ['!'] = 'SH',
    ['t'] = 'TERM',
  }

  ---@return string
  local get_mode = function()
    return table.concat({ ' %#CustomStatusLineMode#', mode_map[vim.fn.mode()], '%*' })
  end

  -- Need the gitsigns plugin
  ---@param color boolean
  ---@return string
  local get_git_info = function(color)
    local hl_map = {
      ['+'] = '%#CustomStatusLineGitAdded#',
      ['~'] = '%#CustomStatusLineGitChanged#',
      ['-'] = '%#CustomStatusLineGitRemoved#',
    }
    local head = (color and '%#CustomStatusLineGitHead#' or '') .. (vim.b.gitsigns_head or '')
    local git_status = vim.fn.split(vim.b.gitsigns_status or '')
    if color then
      for i, v in ipairs(git_status) do
        git_status[i] = hl_map[v:sub(1, 1)] .. v
      end
    end
    local git_status_text = table.concat(git_status, ' ')
    return head .. (git_status_text ~= '' and ' ' or '') .. git_status_text .. '%*'
  end

  -- FIX: There're some problems

  ---@param color boolean
  ---@return string
  local get_diagnostic = function(color)
    local errors = tostring(#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }))
    local warns = tostring(#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }))
    local hints = tostring(#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }))
    local infos = tostring(#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO }))
    local diagnostic = {}
    diagnostic[#diagnostic + 1] = errors ~= '0'
        and ((color and '%#CustomStatusLineDiagnosticError#' or '') .. 'E' .. errors)
      or nil
    diagnostic[#diagnostic + 1] = warns ~= '0'
        and ((color and '%#CustomStatusLineDiagnosticWarn#' or '') .. 'W' .. warns)
      or nil
    diagnostic[#diagnostic + 1] = hints ~= '0'
        and ((color and '%#CustomStatusLineDiagnosticHint#' or '') .. 'H' .. hints)
      or nil
    diagnostic[#diagnostic + 1] = infos ~= '0'
        and ((color and '%#CustomStatusLineDiagnosticInfo#' or '') .. 'I' .. infos)
      or nil
    return table.concat(diagnostic, ' ') .. '%*'
  end

  if vim.api.nvim_get_current_win() == vim.g.statusline_winid then
    return table.concat({
      '%<' .. get_mode() .. ' ',
      '%f %m%y%r%q ',
      get_git_info(true) .. ' ',
      get_diagnostic(true),
      '%=',
      '%{v:register}% %l,%c%V  %P',
      '',
    }, ' ')
  else
    return table.concat({
      '%<',
      '%f %m%y%r%q ',
      get_git_info(false) .. ' ',
      get_diagnostic(false),
      '%=',
      '%{v:register}% %l,%c%V  %P',
      '',
    }, ' ')
  end
end

if global_config.enabled_custom_statusline then
  opt.statusline = '%!v:lua.GetStatusLine()'

  -- auto refresh
  local timer = vim.loop.new_timer()
  ---@diagnostic disable-next-line
  timer:start(
    0,
    1000,
    vim.schedule_wrap(function()
      vim.cmd('redrawstatus')
    end)
  )
end

-- =============================================================================
-- Commands and Aliases
-- Tags: CMD, COMMAND, COMMANDS
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

vim.cmd.cabbrev('rnu set relativenumber')
vim.cmd.cabbrev('nornu set norelativenumber')

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

-- Go to last loc when opening a buffer
create_autocmd('BufReadPost', {
  callback = function()
    local mark = api.nvim_buf_get_mark(0, '"')
    local lcount = api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
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

-- Events
---@diagnostic disable-next-line: param-type-mismatch
create_autocmd({ 'BufReadPost', 'BufWritePost', 'BufNewFile' }, {
  group = create_augroup('FileOpened', { clear = true }),
  pattern = '*',
  callback = function()
    ---@diagnostic disable-next-line: param-type-mismatch
    api.nvim_exec_autocmds('User', { pattern = 'FileOpened', modeline = false })
  end,
})

-- =============================================================================
-- Plugins
-- Tags: PLUG, PLUGIN, PLUGINS
-- =============================================================================

-- LAZYNVIM
local lazy_config = {
  defaults = {
    version = false, -- always use the latest git commit
  },
  install = { colorscheme = { 'catppuccin', 'gruvbox', 'habamax' } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  ui = {
    icons = {},
    border = global_config.border,
    backdrop = 100,
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        'gzip',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
}

local plugins = {

  -- CATPPUCCIN, COLORSCHEME
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
      require('catppuccin').setup({
        flavour = 'macchiato',
        float = {
          transparent = true,
        },
        styles = {
          comments = {},
          conditionals = { 'italic' },
          loops = {},
          functions = { 'bold' },
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        lsp_styles = {
          virtual_text = {
            errors = {},
            hints = {},
            warnings = {},
            information = {},
            ok = {},
          },
        },
        custom_highlights = function(colors)
          local U = require('catppuccin.utils.colors')
          return {
            CursorLineFold = {
              fg = colors.overlay0,
              bg = U.vary_color(
                { latte = U.lighten(colors.mantle, 0.70, colors.base) },
                U.darken(colors.surface0, 0.64, colors.base)
              ),
            },
            CursorLineSign = {
              bg = U.vary_color(
                { latte = U.lighten(colors.mantle, 0.70, colors.base) },
                U.darken(colors.surface0, 0.64, colors.base)
              ),
            },
            CursorLineNr = {
              fg = colors.lavender,
              bg = U.vary_color(
                { latte = U.lighten(colors.mantle, 0.70, colors.base) },
                U.darken(colors.surface0, 0.64, colors.base)
              ),
            },

            DiagnosticNumHlError = { fg = colors.red, bold = true },
            DiagnosticNumHlWarn = { fg = colors.yellow, bold = true },
            DiagnosticNumHlHint = { fg = colors.teal, bold = true },
            DiagnosticNumHlInfo = { fg = colors.sky, bold = true },

            CustomStatusLineMode = { bold = true },
            CustomStatusLineGitHead = { fg = colors.green, bold = true },
            CustomStatusLineGitAdded = { fg = colors.green },
            CustomStatusLineGitChanged = { fg = colors.yellow },
            CustomStatusLineGitRemoved = { fg = colors.red },
            CustomStatusLineDiagnosticError = { fg = colors.red, bold = true },
            CustomStatusLineDiagnosticWarn = { fg = colors.yellow, bold = true },
            CustomStatusLineDiagnosticHint = { fg = colors.teal, bold = true },
            CustomStatusLineDiagnosticInfo = { fg = colors.sky, bold = true },

            SnacksIndent = { fg = colors.surface0 },
            SnacksIndentScope = { fg = colors.surface2 },
            SnacksIndentChunk = { fg = colors.surface2 },

            NoiceCmdline = { fg = colors.text, bg = colors.mantle },
          }
        end,
      })

      vim.cmd.colorscheme('catppuccin')
    end,
  },

  -- GRUVBOX, COLORSCHEME
  {
    'ellisonleao/gruvbox.nvim',
    lazy = true,
    priority = 1000,
    config = function()
      create_autocmd('ColorScheme', {
        group = create_augroup('custom_highlights_gruvbox', {}),
        pattern = 'gruvbox',
        callback = function()
          local set_hl = vim.api.nvim_set_hl
          local bg = vim.o.background

          set_hl(0, 'Title', {
            fg = bg == 'dark' and '#b8bb26' or '#79740e',
            bg = bg == 'dark' and '#3c3836' or '#ebdbb2',
            bold = true,
          })

          set_hl(0, 'FoldColumn', { fg = '#928374', bg = bg == 'dark' and '#282828' or '#fbf1c7' })
          set_hl(0, 'CursorLineFold', { fg = '#928374', bg = bg == 'dark' and '#3c3836' or '#ebdbb2' })
          set_hl(0, 'SignColumn', { bg = bg == 'dark' and '#282828' or '#fbf1c7' })
          set_hl(0, 'CursorLineSign', { bg = bg == 'dark' and '#3c3836' or '#ebdbb2' })

          set_hl(0, 'DiagnosticNumHlError', { fg = bg == 'dark' and '#fb4934' or '#9d0006', bold = true })
          set_hl(0, 'DiagnosticNumHlWarn', { fg = bg == 'dark' and '#fabd2f' or '#b57614', bold = true })
          set_hl(0, 'DiagnosticNumHlHint', { fg = bg == 'dark' and '#8ec07c' or '#427b58', bold = true })
          set_hl(0, 'DiagnosticNumHlInfo', { fg = bg == 'dark' and '#83a598' or '#076678', bold = true })

          set_hl(0, 'CustomStatusLineMode', { bold = true })
          set_hl(0, 'CustomStatusLineGitHead', { fg = bg == 'dark' and '#b8bb26' or '#79740e', bold = true })
          set_hl(0, 'CustomStatusLineGitAdded', { fg = bg == 'dark' and '#b8bb26' or '#79740e' })
          set_hl(0, 'CustomStatusLineGitChanged', { fg = bg == 'dark' and '#fe8019' or '#af3a03' })
          set_hl(0, 'CustomStatusLineGitRemoved', { fg = bg == 'dark' and '#fb4934' or '#9d0006' })
          set_hl(0, 'CustomStatusLineDiagnosticError', { fg = bg == 'dark' and '#fb4934' or '#9d0006', bold = true })
          set_hl(0, 'CustomStatusLineDiagnosticWarn', { fg = bg == 'dark' and '#fabd2f' or '#b57614', bold = true })
          set_hl(0, 'CustomStatusLineDiagnosticHint', { fg = bg == 'dark' and '#8ec07c' or '#427b58', bold = true })
          set_hl(0, 'CustomStatusLineDiagnosticInfo', { fg = bg == 'dark' and '#83a598' or '#076678', bold = true })

          set_hl(0, 'GitsignsCurrentLineBlame', { fg = bg == 'dark' and '#7c6f64' or '#a89984' })
          set_hl(0, 'MiniFilesTitleFocused', {
            fg = bg == 'dark' and '#fe8019' or '#af3a03',
            bg = bg == 'dark' and '#3c3836' or '#ebdbb2',
            bold = true,
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
        overrides = {},
      })

      vim.cmd.colorscheme('gruvbox')
    end,
  },

  -- NOICE
  {
    'folke/noice.nvim',
    event = { 'VeryLazy' },
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    init = function()
      opt.cmdheight = 0
    end,
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
      },
      cmdline = {
        enabled = true, -- enables the Noice cmdline UI
        view = 'cmdline_popup', -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
        opts = {}, -- global options for the cmdline. See section on views
        format = {
          -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
          -- view: (default is cmdline view)
          -- opts: any options passed to the view
          -- icon_hl_group: optional hl_group for the icon
          -- title: set to anything or empty string to hide
          cmdline = { pattern = '^:', icon = ' >', lang = 'vim', view = 'cmdline' },
          search_down = { kind = 'search', pattern = '^/', icon = ' Search Down', lang = 'regex' },
          search_up = { kind = 'search', pattern = '^%?', icon = ' Search Up', lang = 'regex' },
          filter = { pattern = '^:%s*!', icon = ' $', lang = 'bash', view = 'cmdline' },
          lua = {
            pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' },
            icon = ' > lua',
            lang = 'lua',
            view = 'cmdline',
          },
          help = { pattern = '^:%s*he?l?p?%s+', icon = ' ?', view = 'cmdline' },
          input = { view = 'cmdline', icon = ' Input' }, -- Used by input()
          -- lua = false, -- to disable a format, set to `false`
        },
      },
      views = {
        mini = {
          timeout = 5000,
          focusable = true,
          position = {
            row = -1,
            col = -1,
          },
          size = {
            width = 'auto',
            height = 'auto',
            max_height = 100,
          },
        },
      },
      routes = {
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = '%d+L, %d+B' },
              { find = '; after #%d+' },
              { find = '; before #%d+' },
            },
          },
          view = 'mini',
        },
      },
    },
  },

  -- LUALINE
  {
    'nvim-lualine/lualine.nvim',
    event = { 'VeryLazy', 'User FileOpened' },
    init = function()
      opt.laststatus = 0
      opt.showtabline = 0
    end,
    config = function()
      require('lualine').setup({
        options = {
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = { 'ministarter' },
          },
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            {
              'tabs',
              mode = 2,
              path = 1,
              use_mode_colors = true,
            },
          },
          lualine_c = {
            'branch',
            'diff',
            {
              'diagnostics',
              symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
            },
          },
          lualine_x = {
            {
              function()
                return require('noice').api.status.command.get()
              end,
              cond = function()
                return package.loaded['noice'] and require('noice').api.status.command.has()
              end,
              color = function()
                return { fg = Utils.get_hl('Statement') }
              end,
            },
            {
              function()
                return require('noice').api.status.mode.get()
              end,
              cond = function()
                return package.loaded['noice'] and require('noice').api.status.mode.has()
              end,
              color = function()
                return { fg = Utils.get_hl('Constant') }
              end,
            },
            {
              function()
                return '  ' .. require('dap').status()
              end,
              cond = function()
                return package.loaded['dap'] and require('dap').status() ~= ''
              end,
              color = function()
                return { fg = Utils.get_hl('Debug') }
              end,
            },
            {
              require('lazy.status').updates,
              cond = require('lazy.status').has_updates,
              color = function()
                return { fg = Utils.get_hl('Special') }
              end,
            },
            'searchcount',
            'encoding',
            'fileformat',
            'filetype',
          },
          lualine_y = { 'progress', 'location' },
          lualine_z = {
            function()
              return os.date('%R')
            end,
          },
        },
      })
    end,
  },

  -- TSCOMMENTS, TS-COMMENTS
  {
    'folke/ts-comments.nvim',
    opts = {
      lang = {
        c = {
          '/* %s */',
          '// %s',
        },
      },
    },
    event = 'VeryLazy',
    enabled = vim.fn.has('nvim-0.10.0') == 1,
  },

  -- MINI.STARTER
  {
    'nvim-mini/mini.starter',
    lazy = false,
    dependencies = {
      'nvim-mini/mini.icons',
    },
    keys = {
      { '<leader>ts', '<cmd>MiniStarterToggle<CR>' },
    },
    config = function()
      vim.cmd([[autocmd User MiniStarterOpened setlocal nofoldenable fillchars=eob:\ ]])

      local starter = require('mini.starter')

      local version = function()
        local v = vim.version()
        local prerelease = v.api_prerelease and '(Pre-release) v' or 'v'
        return 'NVIM ' .. prerelease .. tostring(vim.version())
      end

      local header = function()
        return version()
          .. '\n\n'
          .. [[
Nvim is open source and freely distributable
https://neovim.io/#chat

This Configuration:
https://github.com/gczcn/dotfile/blob/main/nvim/.config/nvim/init.lua]]
      end

      local footer = function()
        return os.date()
      end

      ---@param n integer|nil
      ---@param the_char_before_index string
      ---@param index integer
      ---@param current_dir string|boolean|nil
      ---@param show_path boolean|function|nil
      ---@param show_icons boolean|function|nil
      -- stylua: ignore start
      local recent_files = function(n, the_char_before_index, index, current_dir, show_path, show_icons)
        n = n or 5
        if current_dir == nil then current_dir = false end

        if show_path == nil then show_path = true end
        if show_path == false then show_path = function() return '' end end
        if show_path == true then
          show_path = function(path) return string.format(' (%s)', vim.fn.fnamemodify(path, ':~:.')) end
        end

        if show_icons == nil then show_icons = true end
        if show_icons == nil then show_icons = function() return '' end end
        if show_icons == true then
          show_icons = function(file_name)
            local icon, _ = require('nvim-web-devicons').get_icon(file_name)
            if not icon then icon = '󰈔' end
            return icon .. ' '
          end
        end

        return function()
          local section = string.format('Recent files%s', current_dir and ' ' .. current_dir or '')

          -- Use only actual readable files
          local files = vim.tbl_filter(function(f) return vim.fn.filereadable(f) == 1 end, vim.v.oldfiles or {})

          if #files == 0 then
            return { { name = 'There are no recent files (`v:oldfiles` is empty)', action = '', section = section } }
          end

          -- Possibly filter files from current directory
          if current_dir then
            ---@diagnostic disable-next-line: undefined-field
            local sep = vim.loop.os_uname().sysname == 'Windows_NT' and [[%\]] or '%/'
            local cwd_pattern = '^' .. vim.pesc(vim.fn.getcwd()) .. sep
            -- Use only files from current directory and its subdirectories
            files = vim.tbl_filter(function(f) return f:find(cwd_pattern) ~= nil end, files)
          end

          if #files == 0 then
            return { { name = 'There are no recent files in current directory', action = '', section = section } }
          end

          -- Create items
          ---@type string|integer
          local i = index or ''
          local items = {}
          for _, f in ipairs(vim.list_slice(files, 1, n)) do
            local file_name = vim.fn.fnamemodify(f, ':t')
            local name = the_char_before_index
              .. (i ~= '' and (i ~= 10 and i .. ' ' or '0 ') or '')
              .. show_icons(file_name)
              .. file_name
              .. show_path(f)
            i = i == '' and '' or i + 1
            items[#items + 1] = { action = 'edit ' .. f, name = name, section = section }
          end

          return items
        end
      end
      -- stylua: ignore end

      starter.setup({
        evaluate_single = true,
        items = {
          -- Recent files (Current directory)
          recent_files(5, '', 1, vim.fn.getcwd()),

          -- Recent files
          recent_files(5, '`', 1),

          -- Builtin actions
          -- stylua: ignore start
          { name = 'n New buffer', action = ':ene', section = 'Builtin actions' },
          { name = 'q Quit neovim', action = ':q', section = 'Builtin actions' },
          { name = 'o Configuration file', action = ':e ' .. vim.fn.stdpath('config') .. '/init.lua', section = 'Builtin actions' },

          -- Plugins actions
          { name = 'u Sync plugins', action = ':Lazy sync', section = 'Plugins actions' },
          { name = 'p Plugins', action = ':Lazy', section = 'Plugins actions' },
          { name = 's Smart picker', action = ':lua Snacks.picker.smart()', section = 'Plugins actions' },
          { name = 'e File browser', action = ':lua require("mini.files").open()', section = 'Plugins actions' },
          { name = 'r File browser (config)', action = ':lua require("mini.files").open("' .. vim.fn.stdpath('config') .. '")', section = 'Plugins actions' },
          { name = 'f Find files', action = ':lua Snacks.picker.files()', section = 'Plugins actions' },
          { name = 'c Find config', action = ':lua Snacks.picker.files({ cwd = vim.fn.stdpath("config") })', section = 'Plugins actions' },
          { name = 'g Live grep', action = ':lua Snacks.picker.grep()', section = 'Plugins actions' },
          { name = 'k Keymaps', action = ':lua Snacks.picker.keymaps()', section = 'Plugins actions' },
          { name = 'm Man page', action = ':lua Snacks.picker.man()', section = 'Plugins actions' },
          { name = 'h Help', action = ':lua Snacks.picker.man()', section = 'Plugins actions' },
          { name = 'w Colorscheme', action = ':lua Snacks.picker.colorscheme()', section = 'Plugins actions' },
          { name = 'z Zoxide', action = ':lua Snacks.picker.zoxide()', section = 'Plugins actions' },
          -- stylua: ignore end
        },
        content_hooks = {
          starter.gen_hook.padding(7, 3),
          -- starter.gen_hook.adding_bullet('▏ '),
          starter.gen_hook.adding_bullet('░ '),
        },
        header = header(),
        footer = footer(),
        query_updaters = 'abcdefghijklmnopqrstuvwxyz0123456789_-.`',
        silent = true,
      })

      create_user_command('MiniStarterToggle', function()
        if vim.o.filetype == 'ministarter' then
          require('mini.starter').close()
        else
          require('mini.starter').open()
        end
      end, {})

      create_autocmd('User', {
        pattern = 'LazyVimStarted',
        callback = function(ev)
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          starter.config.footer = 'loaded '
            .. stats.loaded
            .. '/'
            .. stats.count
            .. ' plugins in '
            .. ms
            .. 'ms\n'
            .. footer()
          if vim.bo[ev.buf].filetype == 'ministarter' then
            pcall(starter.refresh)
          end
        end,
      })
    end,
  },

  -- MINI.FILES, FILES_MANAGER
  {
    'nvim-mini/mini.files',
    dependencies = {
      'nvim-mini/mini.icons',
    },
    keys = {
      -- stylua: ignore start
      ---@diagnostic disable-next-line: undefined-global
      { '<leader>e', function() MiniFiles.open() end },
      ---@diagnostic disable-next-line: undefined-global
      { '<leader>E', function() MiniFiles.open(api.nvim_buf_get_name(0)) end },
      -- stylua: ignore end
    },
    init = function()
      local mini_files_open_folder = function(path)
        require('mini.files').open(path)
      end
      Utils.autocmd_attach_file_browser('mini.files', mini_files_open_folder)
    end,
    config = function()
      ---@diagnostic disable-next-line: param-type-mismatch
      create_autocmd('User', {
        pattern = 'MiniFilesActionRename',
        callback = function(event)
          ---@diagnostic disable-next-line: undefined-global
          Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
      require('mini.files').setup({
        mappings = {
          close = 'q',
          go_in = '<S-CR>',
          go_in_plus = '<CR>',
          go_out = '<BS>',
          go_out_plus = '<S-BS>',
          mark_goto = "'",
          mark_set = 'm',
          reset = '-',
          reveal_cwd = '@',
          show_help = 'g?',
          synchronize = '=',
          trim_left = '<',
          trim_right = '>',
        },
        options = {
          permanent_delete = true,
          use_as_default_explorer = false,
        },
      })
    end,
  },

  -- MINI.ICONS
  {
    'nvim-mini/mini.icons',
    lazy = true,
    opts = {
      style = 'glyph',
      file = {
        ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
        ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
      },
      filetype = {
        dotenv = { glyph = '', hl = 'MiniIconsYellow' },
        go = { glyph = '', hl = 'MiniIconsBlue' },
      },
    },
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },

  -- MINI.SURROUND
  {
    'nvim-mini/mini.surround',
    keys = {
      { 'sa', mode = { 'n', 'v' } },
      'sd',
      'sf',
      'sF',
      'sh',
      'sr',
      'sn',
    },
    config = function()
      require('mini.surround').setup({
        mappings = {
          add = 'sa', -- Add surrounding in Normal and Visual modes
          delete = 'sd', -- Delete surrounding
          find = 'sf', -- Find surrounding (to the right)
          find_left = 'sF', -- Find surrounding (to the left)
          highlight = 'sh', -- Highlight surrounding
          replace = 'sr', -- Replace surrounding
          update_n_lines = 'sn', -- Update `n_lines`
        },
      })
    end,
  },

  -- NVIM_TREESITTER
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    version = false,
    build = ':TSUpdate',
    event = { 'User FileOpened', 'VeryLazy' },
    cmd = { 'TSUpdate', 'TSInstall', 'TSLog', 'TSUninstall' },
    keys = {
      {
        'af',
        function()
          require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
        end,
        mode = { 'x', 'o' },
      },
      {
        'kf',
        function()
          require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
        end,
        mode = { 'x', 'o' },
      },
      {
        'ac',
        function()
          require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
        end,
        mode = { 'x', 'o' },
      },
      {
        'kc',
        function()
          require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
        end,
        mode = { 'x', 'o' },
      },
      {
        'as',
        function()
          require('nvim-treesitter-textobjects.select').select_textobject('@local.scope', 'locals')
        end,
        mode = { 'x', 'o' },
      },
    },
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    config = function()
      local treesitter = require('nvim-treesitter')

      -- Install parsers without showing the 'x/x parsers installed' message
      local ensureInstalled = {
        'lua',
        'luadoc',
        'luap',
        'python',
        'c',
        'dart',
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
        'go',
        'kotlin',
      }
      local alreadyInstalled = require('nvim-treesitter.config').get_installed()
      local parsersToInstall = vim
        .iter(ensureInstalled)
        :filter(function(parser)
          return not vim.tbl_contains(alreadyInstalled, parser)
        end)
        :totable()
      treesitter.install(parsersToInstall)

      create_autocmd('FileType', {
        group = create_augroup('nvim_treesitter_filetype', { clear = true }),
        callback = function(ev)
          ---@return table
          local get_installed_parsers = function()
            local installed = {}
            for _, lang in ipairs(treesitter.get_installed('parsers')) do
              installed[lang] = true
            end
            return installed
          end

          ---@param ft string
          ---@return boolean
          local has_parser = function(ft)
            local lang = vim.treesitter.language.get_lang(ft)
            return not (lang == nil or get_installed_parsers()[lang] == nil)
          end

          if has_parser(ev.match) then
            pcall(vim.treesitter.start, ev.buf)
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.wo.foldtext = 'v:lua.vim.treesitter.foldtext()'
            -- vim.bo.indentexpr = 'v:lua.require"nvim-treesitter".indentexpr()'
          end
        end,
      })

      require('nvim-treesitter-textobjects').setup({})
    end,
  },
  -- {
  --   'nvim-treesitter/nvim-treesitter',
  --   enabled = true,
  --   version = false,
  --   event = { 'User FileOpened', 'BufAdd', 'VeryLazy' },
  --   cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
  --   keys = {
  --     -- context
  --     { '[c', function() require('treesitter-context').go_to_context() end, mode = 'n' },
  --   },
  --   build = ':TSUpdate',
  --   dependencies = {
  --     'nvim-treesitter/nvim-treesitter-textobjects',
  --     -- 'nvim-treesitter/nvim-treesitter-context',
  --     -- { 'HiPhish/rainbow-delimiters.nvim', submodules = false },
  --   },
  --   init = function(plugin)
  --     require('lazy.core.loader').add_to_rtp(plugin)
  --     require('nvim-treesitter.query_predicates')
  --   end,
  --   config = function()
  --     ---@diagnostic disable-next-line: missing-fields
  --     require('nvim-treesitter.configs').setup({
  --       ensure_installed = {
  --         'lua',
  --         'luadoc',
  --         'luap',
  --         'python',
  --         'c',
  --         'dart',
  --         'html',
  --         'vim',
  --         'vimdoc',
  --         'javascript',
  --         'typescript',
  --         'bash',
  --         'diff',
  --         'jsdoc',
  --         'json',
  --         'jsonc',
  --         'toml',
  --         'yaml',
  --         'tsx',
  --         'markdown',
  --         'markdown_inline',
  --         'regex',
  --         'c_sharp',
  --         'go',
  --         'kotlin',
  --       },
  --       -- auto_install = true,
  --       highlight = {
  --         enable = true,
  --         additional_vim_regex_highlighting = false,
  --       },
  --       indent = {
  --         enable = true,
  --       },
  --       incremental_selection = {
  --         enable = false,
  --         keymaps = {
  --           init_selection = '<CR>',
  --           node_incremental = '<CR>',
  --           node_decremental = '<BS>',
  --           -- scope_incremental = '<TAB>',
  --         },
  --       },
  --       textobjects = {
  --         select = {
  --           disable = { 'dart' },
  --           enable = true,
  --           lookahead = true,
  --           keymaps = {
  --             ['af'] = '@function.outer',
  --             ['kf'] = '@function.inner',
  --             ['ac'] = '@class.outer',
  --             ['kc'] = '@class.inner',
  --           }
  --         },
  --       },
  --     })
  --
  --     -- HACK: temporary fix to ensure rainbow delimiters are highlighted in real-time
  --     create_autocmd('BufRead', {
  --       desc = 'Ensure treesitter is initialized???',
  --       callback = function()
  --         pcall(vim.treesitter.start)
  --       end,
  --     })
  --
  --     -- create_autocmd({ 'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter' }, {
  --     --   group = create_augroup('TS_FOLD_WORKAROUND', {}),
  --     --   callback = function()
  --     --     if require('nvim-treesitter.parsers').has_parser() then
  --     --       opt.foldmethod = 'expr'
  --     --       opt.foldexpr = 'nvim_treesitter#foldexpr()'
  --     --     else
  --     --       opt.foldmethod = 'syntax'
  --     --     end
  --     --   end,
  --     -- })
  --   end,
  -- },

  -- ANTONYM
  {
    'gczcn/antonym.nvim',
    cmd = 'AntonymWord',
    keys = {
      { '<leader>ta', '<cmd>AntonymWord<CR>' },
    },
    config = function()
      require('antonym').setup()
    end,
  },

  -- MOVE
  {
    'fedepujol/move.nvim',
    cmd = { 'MoveLine', 'MoveHChar', 'MoveWord', 'MoveBlock', 'MoveHBlock' },
    keys = {
      { '-', ':MoveLine(-1)<CR>', mode = 'n', noremap = true, silent = true },
      { '+', ':MoveLine(1)<CR>', mode = 'n', noremap = true, silent = true },
      { '<C-n>', ':MoveHChar(-1)<CR>', mode = 'n', noremap = true, silent = true },
      { '<C-e>', ':MoveHChar(1)<CR>', mode = 'n', noremap = true, silent = true },
      { '<leader>wf', ':MoveWord(1)<CR>', mode = 'n', noremap = true, silent = true },
      { '<leader>wb', ':MoveWord(-1)<CR>', mode = 'n', noremap = true, silent = true },

      { '-', ':MoveBlock(-1)<CR>', mode = 'v', noremap = true, silent = true },
      { '+', ':MoveBlock(1)<CR>', mode = 'v', noremap = true, silent = true },
      { '<C-n>', ':MoveHBlock(-1)<CR>', mode = 'v', noremap = true, silent = true },
      { '<C-e>', ':MoveHBlock(1)<CR>', mode = 'v', noremap = true, silent = true },
    },
    config = function()
      require('move').setup({ char = { enable = true } })
    end,
  },

  -- MULTI-CURSOR
  {
    'jake-stewart/multicursor.nvim',
    keys = function()
      -- stylua: ignore
      return {
        { '<up>', function() require('multicursor-nvim').lineAddCursor(-1) end, mode = { 'n', 'v' } },
        { '<down>', function() require('multicursor-nvim').lineAddCursor(1) end, mode = { 'n', 'v' } },
        { '<leader><up>', function() require('multicursor-nvim').lineSkipCursor(-1) end, mode = { 'n', 'v' } },
        { '<leader><down>', function() require('multicursor-nvim').lineSkipCursor(1) end, mode = { 'n', 'v' } },
        { '<M-K>', function() require('multicursor-nvim').matchAddCursor(-1) end, mode = { 'n', 'v' } },
        { '<M-k>', function() require('multicursor-nvim').matchAddCursor(1) end, mode = { 'n', 'v' } },
        { '<M-Q>', function() require('multicursor-nvim').matchSkipCursor(-1) end, mode = { 'n', 'v' } },
        { '<M-q>', function() require('multicursor-nvim').matchSkipCursor(1) end, mode = { 'n', 'v' } },
        { '<leader>A', function() require('multicursor-nvim').matchAllAddCursors() end, mode = { 'n', 'v' } },
        { '<left>', function() require('multicursor-nvim').prevCursor() end, mode = { 'n', 'v' } },
        { '<right>', function() require('multicursor-nvim').nextCursor() end, mode = { 'n', 'v' } },
        { '<leader>x', function() require('multicursor-nvim').deleteCursor() end, mode = { 'n', 'v' } },
        { '<C-q>', function() require('multicursor-nvim').toggleCursor() end, mode = { 'n', 'v' } },
        { '<leader><C-q>', function() require('multicursor-nvim').duplicateCursors() end, mode = { 'n', 'v' } },
        { '<ESC>', function()
          if not require('multicursor-nvim').cursorsEnabled() then
            require('multicursor-nvim').enableCursors()
          elseif require('multicursor-nvim').hasCursors() then
            require('multicursor-nvim').clearCursors()
          end
        end, mode = 'n' },
        { '<leader>gv', function() require('multicursor-nvim').restoreCursors() end, mode = 'n' },
        { '<leader>ac', function() require('multicursor-nvim').alignCursors() end, mode = 'n' },
        { 'S', function() require('multicursor-nvim').splitCursor() end, mode = 'v' },
        { 'M', function() require('multicursor-nvim').matchCursors() end, mode = 'v' },
        { '<leader>tc', function() require('multicursor-nvim').transposeCursors(1) end, mode = 'v' },
        { '<leader>Tc', function() require('multicursor-nvim').transposeCursors(-1) end, mode = 'v' },
        { '<C-i>', function() require('multicursor-nvim').jumpForward() end, mode = { 'n', 'v' } },
        { '<C-o>', function() require('multicursor-nvim').jumpBackward() end, mode = { 'n', 'v' } },
      }
    end,
    config = function()
      require('multicursor-nvim').setup()

      -- Customize how cursors look.
      local hl = api.nvim_set_hl
      hl(0, 'MultiCursorCursor', { link = 'Cursor' })
      hl(0, 'MultiCursorVisual', { link = 'Visual' })
      hl(0, 'MultiCursorSign', { link = 'SignColumn' })
      hl(0, 'MultiCursorDisabledCursor', { link = 'Visual' })
      hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
      hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
    end,
  },

  -- FLASH
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      search = {
        exclude = {
          'flash_prompt',
          'bigfile',
          function(win)
            -- exclude non-focusable windows
            return not vim.api.nvim_win_get_config(win).focusable
          end,
        },
      },
      modes = {
        -- char = {
        --   enabled = false,
        -- },
      },
      -- labels = 'asdfghjklqwertyuiopzxcvbnm', -- Qwerty
      labels = 'arstdhneiqwfpgjluy;zxcvbkm', -- Colemak
      prompt = {
        prefix = { { ' Jump ', 'FlashPromptIcon' } },
      },
    },
    -- stylua: ignore
    keys = {
      { '\\', function() require('flash').jump() end, mode = { 'n', 'x', 'o', 'v' }, desc = 'Flash' },
      { '<CR>', function() require('flash').treesitter() end, mode = { 'n', 'o', 'v' }, desc = 'Flash Treesitter Incremental Selection' },
      { '<leader>\\', function() require('flash').remote() end, mode = 'o', desc = 'Remote Flash' },
      { '<leader>|', function() require('flash').treesitter_search() end, mode = { 'o', 'x', 'v' }, desc = 'Treesitter Search' },
      { '<C-s>', function() require('flash').toggle() end, mode = 'c', desc = 'Toggle Flash Search' },
    },
  },

  -- MARKDOWN-PREVIEW
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    keys = { { '<leader>m', '<cmd>MarkdownPreviewToggle<CR>' } },
    ft = { 'markdown' },
    build = function()
      require('lazy').load({ plugins = { 'markdown-preview.nvim' } })
      vim.fn['mkdp#util#install']()
    end,
    init = function()
      vim.cmd([[
let g:mkdp_command_for_global = 1
let g:mkdp_page_title = '"${name}"'
" let g:mkdp_theme = 'light'
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 1,
    \ 'toc': {}
    \ }
]])
    end,
  },

  -- CODERUNNER, RUNCODE
  {
    'CRAG666/code_runner.nvim',
    cmd = {
      'RunCode',
      'RunFile',
      'RunProject',
      'RunClose',
      'CRFiletype',
      'CRProjects',
    },
    keys = {
      {
        '<leader>ra',
        function()
          vim.ui.input({ prompt = 'Input Args: ' }, function(args)
            if args ~= nil then
              vim.g.code_runner_run_args = args
            end
          end)
        end,
      },
      {
        '<leader>R',
        function()
          vim.ui.input({ prompt = 'Input Args: ' }, function(args)
            if args ~= nil then
              vim.g.code_runner_run_args = args
              vim.cmd.RunCode()
              vim.g.code_runner_run_args = ''
            end
          end)
        end,
      },
      { '<leader>r', '<cmd>RunCode<CR>' },
      { '<leader>rr', '<cmd>RunCode<CR>' },
      { '<leader>rf', '<cmd>RunFile<CR>' },
      { '<leader>rft', '<cmd>RunFile tab<CR>' },
      { '<leader>rp', '<cmd>RunProject<CR>' },
      { '<leader>rc', '<cmd>RunClose<CR>' },
      { '<leader>crf', '<cmd>CRFiletype<CR>' },
      { '<leader>crp', '<cmd>CRProjects<CR>' },
    },
    config = function()
      vim.g.code_runner_run_args = ''
      require('code_runner').setup({
        term = {
          size = 20,
        },
        filetype = {
          java = {
            'cd $dir &&',
            'javac $fileName &&',
            'java $fileNameWithoutExt',
          },
          python = function()
            return 'python3 $file ' .. vim.g.code_runner_run_args
          end,
          dart = function()
            return 'dart run $file ' .. vim.g.code_runner_run_args
          end,
          go = function()
            return 'go run $file ' .. vim.g.code_runner_run_args
          end,
          lua = function()
            return 'lua $file ' .. vim.g.code_runner_run_args
          end,
          typescript = 'deno run',
          rust = {
            'cd $dir &&',
            'rustc $fileName &&',
            '$dir/$fileNameWithoutExt',
          },
          c = function()
            local c_base = {
              'cd $dir &&',
              'gcc-14 --std=gnu23 $fileName -o', -- for homebrew
              -- 'gcc --std=gnu23 $fileName -o',
              -- 'clang $fileName -o',
              '/tmp/$fileNameWithoutExt',
            }
            local c_exec = {
              '&& /tmp/$fileNameWithoutExt &&',
              'rm /tmp/$fileNameWithoutExt',
            }
            vim.ui.input({ prompt = 'Add more args: ' }, function(input)
              c_base[4] = input
              vim.print(vim.tbl_extend('force', c_base, c_exec))
              require('code_runner.commands').run_from_fn(vim.list_extend(c_base, c_exec))
            end)
          end,
        },
      })
    end,
  },

  -- SUDA, SUDO
  {
    'lambdalisue/vim-suda',
    enabled = (vim.fn.has('win16') or vim.fn.has('win32') or vim.fn.has('win64')) and false or true,
    event = { 'VeryLazy', 'User FileOpened' },
    cmd = { 'SudaWrite', 'SudaRead' },
    config = function()
      vim.cmd.cabbrev('ww SudaWrite')
      vim.cmd.cabbrev('wwr SudaRead')
    end,
  },

  -- COLORIZER
  -- test: #000000, #ffffff, #ff0000, #00ff00, #0000ff
  {
    'catgoose/nvim-colorizer.lua',
    event = 'VeryLazy',
    config = function()
      require('colorizer').setup({
        user_default_options = {
          -- mode = 'virtualtext',
          -- virtualtext = '■',
          -- virtualtext_inline = 'before',
          always_update = true,
        },
      })

      if vim.fn.has('nvim-0.12.0') == 1 then
        create_autocmd('LspAttach', {
          callback = function()
            vim.lsp.document_color.enable(false)
          end,
        })
      end

      vim.cmd.ColorizerReloadAllBuffers()
      vim.cmd.ColorizerToggle()
    end,
  },

  -- SNACKS
  {
    'folke/snacks.nvim',
    lazy = false,
    priority = 1000,
    keys = {
      { '<leader>rN', '<cmd>lua Snacks.rename.rename_file()<CR>' },

      { '<leader>ff', '<cmd>lua Snacks.picker.files()<CR>' },
      { '<leader>fc', '<cmd>lua Snacks.picker.files({ cwd = vim.fn.stdpath("config") })<CR>' },
      { '<leader>fr', '<cmd>lua Snacks.picker.recent()<CR>' },
      { '<leader>fg', '<cmd>lua Snacks.picker.grep()<CR>' },
      { '<leader>fk', '<cmd>lua Snacks.picker.keymaps()<CR>' },
      { '<leader>fb', '<cmd>lua Snacks.picker.buffers()<CR>' },
      { '<leader>fm', '<cmd>lua Snacks.picker.man()<CR>' },
      { '<leader>fh', '<cmd>lua Snacks.picker.help()<CR>' },
      { '<leader>fu', '<cmd>lua Snacks.picker.undo()<CR>' },
      { '<leader>fz', '<cmd>lua Snacks.picker.zoxide()<CR>' },
      { '<leader>fw', '<cmd>lua Snacks.picker.colorschemes()<CR>' },
      { '<leader>fs', '<cmd>lua Snacks.picker.smart()<CR>' },
      -- { '<leader>fn', '<cmd>lua Snacks.picker.notifications()<CR>' },

      -- Lsp
      { 'grr', '<cmd>lua Snacks.picker.lsp_references()<CR>', desc = 'Show LSP References' },
      { 'gd', '<cmd>lua Snacks.picker.lsp_definitions()<CR>', desc = 'Show LSP Definitions' },
      { 'gD', '<cmd>lua Snacks.picker.lsp_declarations()<CR>', desc = 'Show LSP Declarations' },
      { 'gri', '<cmd>lua Snacks.picker.lsp_implementations()<CR>', desc = 'Show LSP Implementations' },
      { 'grt', '<cmd>lua Snacks.picker.lsp_type_definitions()<CR>', desc = 'Show LSP Type Definitions' },
      { '<leader>;', '<cmd>lua Snacks.picker.lsp_symbols()<CR>', desc = 'Show Buffer Symbols' },
      { '<leader>D', '<cmd>lua Snacks.picker.diagnostics_buffer()<CR>', desc = 'Show Buffer Diagnostics' },
    },
    config = function()
      local Snacks = require('snacks')
      Snacks.setup({
        bigfile = {
          setup = function(ctx)
            if ctx.ft == 'markdown' then
              Utils.setup_markdown()
            end
            if vim.fn.exists(':NoMatchParen') ~= 0 then
              vim.cmd([[NoMatchParen]])
            end
            Snacks.util.wo(0, { foldmethod = 'manual', statuscolumn = '', conceallevel = 0 })
            vim.b.completion = false
            vim.b.minianimate_disable = true
            vim.b.minihipatterns_disable = true
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(ctx.buf) then
                vim.bo[ctx.buf].syntax = ctx.ft
              end
            end)
          end,
        },
        picker = {
          prompt = ' ',
          actions = {
            flash = function(picker)
              require('flash').jump({
                pattern = '^',
                label = { after = { 0, 0 } },
                search = {
                  mode = 'search',
                  exclude = {
                    function(win)
                      return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'snacks_picker_list'
                    end,
                  },
                },
                action = function(match)
                  local idx = picker.list:row2idx(match.pos[1])
                  picker.list:_move(idx, true, true)
                end,
              })
            end,
          },
          layout = {
            layout = {
              box = 'horizontal',
              backdrop = false,
              width = 0.9,
              min_width = 120,
              height = 0.85,
              border = 'none',
              {
                box = 'vertical',
                border = global_config.border,
                { win = 'input', height = 1, border = 'bottom' },
                { win = 'list', border = 'none' },
              },
              {
                win = 'preview',
                border = global_config.border,
                width = 0.5,
              },
            },
          },
          win = {
            input = {
              keys = {
                ['<a-s>'] = { 'flash', mode = { 'n', 'i' } },
                ['\\'] = { 'flash' },
                ['<c-e>'] = { 'list_down', mode = { 'i', 'n' } },
                ['<c-u>'] = { 'list_up', mode = { 'i', 'n' } },
              },
            },
          },
        },
        indent = {
          indent = { char = '▏' },
          scope = { char = '▏' },
          animate = { enabled = false },
        },
        quickfile = {},
        styles = {},
      })
    end,
  },

  -- STATUSCOL
  {
    'luukvbaal/statuscol.nvim',
    event = { 'VeryLazy', 'User FileOpened' },
    config = function()
      local builtin = require('statuscol.builtin')
      require('statuscol').setup({
        relculright = true,
        ft_ignore = {
          'ministarter',
        },
        segments = {
          {
            text = { builtin.foldfunc },
            click = 'v:lua.ScFa',
          },
          {
            click = 'v:lua.ScSa',
            sign = {
              name = { '.*' },
              text = { '.*' },
              namespace = { '.*' },
              maxwidth = 1,
              colwidth = 1,
              fillchar = ' ',
            },
          },
          {
            text = { builtin.lnumfunc, ' ' },
            condition = { true, builtin.not_empty },
            click = 'v:lua.ScLa',
          },
        },
      })
    end,
  },

  -- COPILOT
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    enabled = global_config.enabled_copilot,
    config = function()
      require('copilot').setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = '<M-a>',
            accept_word = false,
            accept_line = false,
            next = '<M-{>',
            prev = '<M-}>',
            dismiss = '<C-}>',
          },
        },
      })
    end,
  },

  -- CONFORM, FORMATTER
  {
    'stevearc/conform.nvim',
    cmd = { 'ConformInfo' },
    keys = {
      {
        -- Customize or remove this keymap to your liking
        '<leader>cf',
        function()
          require('conform').format({ async = true })
        end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        javascript = { { 'prettierd', 'prettier' } },
        c = { 'clang-format' },
        go = { 'gofmt' },
      },
      formatters = {
        shfmt = {
          prepend_args = { '-i', '2' },
        },
      },
    },
  },

  -- GITSIGNS
  {
    'lewis6991/gitsigns.nvim',
    event = { 'User FileOpened' },
    enabled = true,
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '▍' },
          change = { text = '▍' },
          delete = { text = '▁' },
          topdelete = { text = '▔' },
          changedelete = { text = '▍' },
          untracked = { text = '▍' },
        },
        signs_staged = {
          add = { text = '▍' },
          change = { text = '▍' },
          delete = { text = '▁' },
          topdelete = { text = '▔' },
          changedelete = { text = '▍' },
          untracked = { text = '▍' },
        },
        sign_priority = 11,
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 0,
        },
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns

          local map = function(mode, l, r, desc)
            keymap.set(mode, l, r, { buffer = buffer, desc = desc })
          end

          -- stylua: ignore start
          map('n', ']h', gs.next_hunk, 'Next Hunk')
          map('n', '[h', gs.prev_hunk, 'Prev Hunk')
          map({ 'n', 'v' }, '<leader>ghs', ':Gitsigns stage_hunk<CR>', 'Stage Hunk')
          map({ 'n', 'v' }, '<leader>ghr', ':Gitsigns reset_hunk<CR>', 'Reset Hunk')
          map('n', '<leader>ghS', gs.stage_buffer, 'Stage Buffer')
          map('n', '<leader>ghu', gs.undo_stage_hunk, 'Undo Stage Hunk')
          map('n', '<leader>ghR', gs.reset_buffer, 'Reset Buffer')
          map('n', '<leader>ghp', gs.preview_hunk_inline, 'Preview Hunk Inline')
          map('n', '<leader>ghb', function() gs.blame_line({ full = true }) end, 'Blame Line')
          map('n', '<leader>ghd', gs.diffthis, 'Diff This')
          map('n', '<leader>ghD', function() gs.diffthis('~') end, 'Diff This ~')
          map({ 'o', 'x' }, 'kh', ':<C-U>Gitsigns select_hunk<CR>', 'GitSigns Select Hunk')
          map('n', '<leader>gl', '<cmd>Gitsigns toggle_linehl<CR>', 'Toggle GitSigns Line Highlight')
        end,
      })
    end,
  },

  -- DAP, DEBUG, DEBUGGER
  {
    'mfussenegger/nvim-dap',
    -- stylua: ignore
    keys = {
      { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = 'Breakpoint Condition' },
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle Breakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = 'Run/Continue' },
      { '<leader>dC', function() require('dap').run_to_cursor() end, desc = 'Run to Cursor' },
      { '<leader>dg', function() require('dap').goto_() end, desc = 'Go to Line (No Execute)' },
      { '<leader>di', function() require('dap').step_into() end, desc = 'Step Into' },
      { '<leader>dj', function() require('dap').down() end, desc = 'Down' },
      { '<leader>dk', function() require('dap').up() end, desc = 'Up' },
      { '<leader>dl', function() require('dap').run_last() end, desc = 'Run Last' },
      { '<leader>do', function() require('dap').step_out() end, desc = 'Step Out' },
      { '<leader>dO', function() require('dap').step_over() end, desc = 'Step Over' },
      { '<leader>dP', function() require('dap').pause() end, desc = 'Pause' },
      { '<leader>dr', function() require('dap').repl.toggle() end, desc = 'Toggle REPL' },
      { '<leader>ds', function() require('dap').session() end, desc = 'Session' },
      { '<leader>dt', function() require('dap').terminate() end, desc = 'Terminate' },
      { '<leader>dw', function() require('dap.ui.widgets').hover() end, desc = 'Widgets' },
    },
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui',
      'leoluz/nvim-dap-go',
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      dapui.setup()

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      require('dap-go').setup()
    end,
  },

  -- TODO: LINT, LINTER
  {
    'mfussenegger/nvim-lint',
    event = { 'User FileOpened' },
    config = function()
      require('lint').linters_by_ft = {
        fish = { 'fish' },
        -- Use the '*' filetype to run linters on all filetypes.
        -- ['*'] = { 'global linter' },
        -- Use the '_' filetype to run linters on filetypes that don't have other linters configured.
        -- ['_'] = { 'fallback linter' },
        -- ['*'] = { 'typos' },
      }
    end,
  },

  -- LSPCONFIG
  {
    'neovim/nvim-lspconfig',
    event = 'User FileOpened',
    keys = {
      { '<leader>cl', '<cmd>LspInfo<CR>', desc = 'Lsp Info' },
    },
    config = function()
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
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
          },
        },
      })

      -- configure C and C++ ... language server
      vim.lsp.config('clangd', {
        cmd = {
          'clangd',
          '--background-index',
        },
      })
    end,
  },

  -- LUASNIP
  {
    'L3MON4D3/LuaSnip',
    event = { 'InsertEnter', 'CmdlineEnter' },
    build = 'make install_jsregexp',
    config = function()
      local ls = require('luasnip')

      keymap.set({ 'i' }, '<C-k>', function()
        ls.expand()
      end, { silent = true })
      keymap.set({ 'i', 's' }, '<C-l>', function()
        ls.jump(1)
      end, { silent = true })
      keymap.set({ 'i', 's' }, '<C-j>', function()
        ls.jump(-1)
      end, { silent = true })

      keymap.set({ 'i', 's' }, '<C-f>', function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true })
    end,
  },

  -- LAZYDEV
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/libraryzzz', words = { 'vim%.uv' } },
        'lazy.nvim',
        'nvim-dap-ui',
      },
    },
  },

  -- BLINKCMP
  {
    'saghen/blink.cmp',
    enabled = true,
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      'rafamadriz/friendly-snippets',
      'L3MON4D3/LuaSnip',
      { 'giuxtaposition/blink-cmp-copilot', enabled = global_config.enabled_copilot },
      { 'zbirenbaum/copilot.lua', enabled = global_config.enabled_copilot },
      'folke/lazydev.nvim',

      {
        'xzbdmw/colorful-menu.nvim',
        config = function()
          require('colorful-menu').setup()
        end,
      },
    },
    version = '*',
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()

      local opts = {
        appearance = {},
        keymap = {
          preset = 'default',
          ['<M-.>'] = { 'show', 'show_documentation', 'hide_documentation' },
          ['<S-TAB>'] = { 'select_prev', 'fallback' },
          ['<TAB>'] = { 'select_next', 'fallback' },
          ['<M-y>'] = { 'accept', 'fallback' },
          ['<Up>'] = { 'fallback' },
          ['<Down>'] = { 'fallback' },
        },
        cmdline = {
          keymap = {
            preset = 'default',
            ['<M-.>'] = { 'show', 'show_documentation', 'hide_documentation' },
            ['<S-TAB>'] = { 'select_prev', 'fallback' },
            ['<TAB>'] = { 'select_next', 'show', 'fallback' },
            ['<M-y>'] = { 'accept', 'fallback' },
            ['<Up>'] = { 'fallback' },
            ['<Down>'] = { 'fallback' },
          },
          completion = {
            list = {
              selection = {
                auto_insert = true,
                preselect = false,
              },
            },
            menu = {
              auto_show = true,
              draw = {
                columns = {
                  { 'label' },
                },
              },
            },
            ghost_text = { enabled = false },
          },
        },
        completion = {
          list = {
            selection = { auto_insert = true, preselect = false },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 0,
            window = {
              -- border = 'single',
              winblend = vim.o.pumblend,
            },
          },
          menu = {
            auto_show = true,
            draw = {
              treesitter = { 'lsp', 'copilot', 'snippets' },
              columns = {
                { 'label' },
                { 'kind_icon', 'kind', gap = 1 },
                -- { 'kind' },
                { 'source_name' },
              },
              components = {
                label = {
                  text = function(ctx)
                    return require('colorful-menu').blink_components_text(ctx)
                  end,
                  highlight = function(ctx)
                    return require('colorful-menu').blink_components_highlight(ctx)
                  end,
                },
                source_name = {
                  width = { max = 30 },
                  text = function(ctx)
                    return '[' .. ctx.source_name .. ']'
                  end,
                  highlight = 'BlinkCmpSource',
                },
              },
            },
            winblend = vim.o.pumblend,
            max_height = 30,
          },
        },
        snippets = { preset = 'luasnip' },
        sources = {
          default = {
            'lazydev',
            'lsp',
            'path',
            'snippets',
            'buffer',
            global_config.enabled_copilot and 'copilot' or nil,
          },
          providers = {
            lazydev = {
              name = 'lazydev',
              module = 'lazydev.integrations.blink',
              -- make lazydev completions top priority (see `:h blink.cmp`)
              score_offset = 100,
            },
          },
        },
      }

      if global_config.enabled_copilot then
        opts.sources.providers.copilot = {
          name = 'copilot',
          module = 'blink-cmp-copilot',
          score_offset = 100,
          async = true,
          transform_items = function(_, items)
            local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
            local kind_idx = #CompletionItemKind + 1
            CompletionItemKind[kind_idx] = 'Copilot'
            for _, item in ipairs(items) do
              item.kind = kind_idx
            end
            return items
          end,
        }
      end

      require('blink.cmp').setup(opts)
    end,
  },
}

-- =============== Lazy.nvim setup ===============
if global_config.enabled_plugins then
  -- Bootstrap lazy.nvim
  local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
  ---@diagnostic disable-next-line: undefined-field
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
      api.nvim_echo({
        { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
        { out, 'WarningMsg' },
        { '\nPress any key to exit...' },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  vim.opt.rtp:prepend(lazypath)

  keymap.set('n', '<leader>als', '<cmd>Lazy sync<CR>', { noremap = true })
  keymap.set('n', '<leader>tl', function()
    if vim.o.filetype == 'lazy' then
      vim.cmd.q()
    else
      vim.cmd.Lazy()
    end
  end)

  require('lazy').setup(plugins, lazy_config)
end
