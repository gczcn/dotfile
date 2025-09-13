-- =============================================================================
-- My Neovim Configuration (Single File Version)
-- https://github.com/gczcn/dotfile/
-- Author: Zixuan Chu <494353540@qq.com>
--
-- Dependencies:
--   Neovim >= 0.11
--   ripgrep - for fzf.lua
--   fd - for fzf.lua
--   make
--   node
--   npm
--   fzf - for fzf.lua
--   gcc
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
-- or you can run :RunShellScripgt<install|update>_deps_<package_manager> to install these dependencies.
--
-- Jump to somewhere by searching for an uppercase tag.
--
-- I hope I can read the code later :)
-- =============================================================================

-- =============================================================================
-- Globar vars
-- Tags: VAR, VARS, GLOBAL
-- =============================================================================

local keymap = vim.keymap
local api = vim.api
local opt = vim.opt
local create_autocmd = api.nvim_create_autocmd
local create_user_command = api.nvim_create_user_command

---@class PluginsConfig
---@field border string[]
---@field nerd_font_circle_and_square boolean
---@field ascii_mode boolean
---@field ivy_layout boolean

---@class global_config
---@field auto_toggle_relativenumber boolean
---@field enabled_plugins boolean
---@field enabled_copilot boolean
---@field enabled_tabnine boolean
---@field plugins_config PluginsConfig
local global_config = {
  enabled_plugins = true,
  enabled_copilot = false,
  enabled_tabnine = false,
  plugins_config = {
    border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
    nerd_font_circle_and_square = true,
    ascii_mode = false,
    ivy_layout = false,
  },
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

-- stylua: ignore start

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
keymap.set('n', 'gcO', function() Utils.commenting.newline('O') end, { desc = 'Add comment on the line above', silent = true })
keymap.set('n', 'gco', function() Utils.commenting.newline('o') end, { desc = 'Add comment on the line below', silent = true })
keymap.set('n', 'gcA', function() Utils.commenting.line_end() end, { desc = 'Add comment at the end of line', silent = true })
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

-- LSP
keymap.set('n', '<leader>cl', '<cmd>LspInfo<CR>', { desc = 'Lsp Info' })
keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'References' })
keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration' })
keymap.set('n', 'gI', vim.lsp.buf.implementation, { desc = 'Goto Implementation' })
keymap.set('n', 'gT', vim.lsp.buf.type_definition, { desc = 'Goto Type Definition' })
keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Actions' })
keymap.set({ 'n', 'v' }, '<leader>cc', vim.lsp.codelens.run, { desc = 'Run Codelens' })
keymap.set('n', '<leader>cC', vim.lsp.codelens.refresh, { desc = 'Refresh & Display Codelens' })
keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Smart Rename' })
keymap.set('n', '<leader>of', vim.diagnostic.open_float, { desc = 'Show Line Diagnostics' })
keymap.set('n', '<M-[>', function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = 'Goto Prev Diagnostic' })
keymap.set('n', '<M-]>', function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = 'Goto Next Diagnostic' })
keymap.set('n', 'U', vim.lsp.buf.hover, { desc = 'Show documentation for what is under cursor' })
keymap.set('n', 'gU', vim.lsp.buf.signature_help, { desc = 'Show documentation for what is under cursor' })
keymap.set('n', '<leader>rs', '<cmd>LspRestart<CR>', { desc = 'Restart LSP' })
keymap.set('n', '<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, { desc = 'Toggle Inlay Hint' })

-- Buffer
keymap.set('n', '<leader>bd', '<cmd>bd<CR>', keymaps_opts)

-- Other
--- Toggle background [ dark | light ]
keymap.set({ 'n', 'v' }, '<F5>', function()
  opt.background = vim.o.background == 'dark' and 'light' or 'dark'
end, keymaps_opts)
keymap.set('n', '<leader>tc', function()
  opt.cursorcolumn = not vim.o.cursorcolumn
end, keymaps_opts)
keymap.set('n', '<leader>l', '<cmd>noh<CR>', keymaps_opts)
keymap.set('n', '<leader>fn', '<cmd>messages<CR>', keymaps_opts)
keymap.set('n', '<leader>oo', '<cmd>e ' .. vim.fn.stdpath('config') .. '/init.lua<CR>')
keymap.set('n', 'gX', function() Utils.goto_github(vim.fn.expand('<cfile>')) end)
keymap.set('n', '<leader><leader>', '<cmd>lua vim.diagnostic.config({virtual_lines=not vim.diagnostic.config().virtual_lines})<CR>')

-- stylua: ignore end

-- =============================================================================
-- Options
-- Tags: OPT, OPTS, OPTION, OPTIONS
-- =============================================================================

vim.g.encoding = 'UTF-8'

opt.autowrite = true
opt.breakindent = true -- Wrap indent to match line start
-- opt.cmdheight = 0 -- Use noice.nvim plugin, no need to display cmdline
opt.colorcolumn = '80' -- Line number reminder
opt.conceallevel = 2 -- Hide * markup for hold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.copyindent = true -- Copy the previous indentation on autoindenting
-- opt.cursorcolumn = true -- Highlight the text column of the cursor
opt.cursorline = true -- Highlight the text line of the cursor
opt.expandtab = true
opt.fileencoding = 'utf-8' -- File content encoding for the buffer
opt.foldcolumn = '1'
opt.guicursor = vim.fn.has('nvim-0.11') == 1
    and 'n-v-sm:block,i-c-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor'
  or 'n-v-sm:block,i-c-ci-ve:ver25,r-cr-o:hor20'
-- opt.fillchars = { foldopen = '▂', foldclose = '▐' }
opt.ignorecase = true -- Ignore case
opt.laststatus = 2
opt.list = true -- Show some hidden characters
opt.listchars = { tab = '> ', trail = '-', extends = '>', precedes = '<', nbsp = '+' }
opt.maxmempattern = 5000
opt.number = true
opt.pumblend = 10
opt.pumheight = 30
-- opt.relativenumber = true
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
-- opt.virtualedit = 'block' -- Allow cursor to move where there is no text in visual block mode
opt.winblend = 10
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

-- ----- UIOPTIONS ----- --
-- FIX: When wrap is enabled, fold column doesn't show correctly
opt.statuscolumn = table.concat({
  '%s', -- Sign column
  '%l', -- Line number
  '%{%(&foldcolumn > 0 && (&signcolumn != "no" || &number || &relativenumber) ? " " : "")%}', -- Gap between SignColumn/number and foldcolumn
  '%C', -- Fold column
  '%#NonText#', -- The highlight for the dividing line
  '%{%(&foldcolumn > 1 ? "▐" : "")%}', -- The dividing line between foldcolumn and buffer
  '%{%(&foldcolumn > 0 || &number || &relativenumber ? " " : "")%}', -- Gap between foldcolumn and buffer
})

-- Need the gitsigns plugin
-- TODO: Diagnostic Info
-- FIX: Need to fix sth
opt.statusline = table.concat({
  '%<', -- See the 'statusline' help file
  '%{mode()} ', -- Current mode
  '%f ', -- File name
  '%h%m%r%y%q ', -- Help buffer, Modified, Readonly, Type and ("[Quickfix List]", "[Location List]" or empty)
  "[%{get(b:,'gitsigns_head','')}] ", -- Git Branch
  "%{get(b:,'gitsigns_status','')}", -- Git Status
  '%=', -- See the 'statusline' help file
  '%{v:register}%-14.(%l,%c%V%)%P', -- Don't care about that
})

if not global_config.enabled_plugins then
  vim.cmd.colorscheme('habamax')
end

-- Lsp
vim.diagnostic.config({
  -- My font does not display the default icon properly.
  -- Need Nerd Font
  virtual_text = global_config.plugins_config.nerd_font_circle_and_square and {
    prefix = '󰝤',
  } or true,
  virtual_lines = false, -- press <leader><leader> to toggle this option.
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

-- =============================================================================
-- Shell Scripts
-- Some shell scripts, mostly used to install dependencies
--
-- I use the package manager that comes with the distribution to manage all
-- neovim dependencies, including language servers and debuggers.
--
-- Tags: SCRIPT, SCRIPTS, SHELLSCRIPT, SHELLSCRIPTS
-- =============================================================================

---@type table<string, string>
local shell_scripts = {
  install_deps_brew = [[
#!/usr/bin/env bash
brew update

brew install ripgrep
brew install fd
brew install node
brew install npm
brew install fzf
brew install gh

# Code Runner
brew install gcc

# Language servers
brew install llvm  # C and C++
brew install typescript-language-server  # Typescript
brew install basedpyright  # Python
brew install lua-language-server  # Lua
brew install gopls  # Go
brew install bash-language-server
brew install fish-lsp
npm install -g vscode-langservers-extracted  # Html, Css...
npm install -g vim-language-server

# Debuggers
brew install delve

# Tools
brew install black
brew install stylua
brew install shfmt]],
  update_deps_brew = [[
#!/usr/bin/env bash
brew update

brew upgrade ripgrep
brew upgrade fd
brew upgrade node
brew upgrade npm
brew upgrade fzf
brew upgrade gh

# Code Runner
brew upgrade gcc

# Language servers
brew upgrade llvm
brew upgrade typescript-language-server
brew install basedpyright
brew upgrade lua-language-server
brew upgrade gopls
brew upgrade bash-language-server
brew upgrade fish-lsp
npm update -g vscode-langservers-extracted
npm update -g vim-language-server

# Debuggers
brew upgrade delve

# Tools
brew upgrade black
brew upgrade stylua
brew upgrade shfmt]],
  install_deps_pacman_and_yay = [[
#!/usr/bin/env bash
sudo pacman -Sy

yes | sudo pacman -S ripgrep
yes | sudo pacman -S fd
yes | sudo pacman -S nodejs
yes | sudo pacman -S npm
yes | sudo pacman -S fzf

# Code Runner
yes | sudo pacman -S gcc

# Language servers
yes | sudo pacman -S llvm
yes | sudo pacman -S clang
yes | sudo pacman -S typescript-language-server
yay -S basedpyright
yes | sudo pacman -S lua-language-server
yes | sudo pacman -S gopls
yes | sudo pacman -S bash-language-server
yes | sudo pacman -S vscode-css-languageserver
yes | sudo pacman -S vscode-html-languageserver
yes | sudo pacman -S vscode-json-languageserver
sudo npm install -g vim-language-server
sudo npm install -g fish-lsp

# Debuggers
yes | sudo pacman -S delve

# Tools
yes | sudo pacman -S python-black
yes | sudo pacman -S stylua
yes | sudo pacman -S shfmt]],
  update_deps_pacman_and_yay = [[
#!/usr/bin/env bash
sudo pacman -Sy

yes | sudo pacman -S ripgrep
yes | sudo pacman -S fd
yes | sudo pacman -S nodejs
yes | sudo pacman -S npm
yes | sudo pacman -S fzf

# Code Runner
yes | sudo pacman -S gcc

# Language servers
yes | sudo pacman -S llvm
yes | sudo pacman -S clang
yes | sudo pacman -S typescript-language-server
yay -S basedpyright
yes | sudo pacman -S lua-language-server
yes | sudo pacman -S gopls
yes | sudo pacman -S bash-language-server
yes | sudo pacman -S vscode-css-languageserver
yes | sudo pacman -S vscode-html-languageserver
yes | sudo pacman -S vscode-json-languageserver
sudo npm update -g vim-language-server
sudo npm update -g fish-lsp

# Debuggers
yes | sudo pacman -S delve

# Tools
yes | sudo pacman -S python-black
yes | sudo pacman -S stylua
yes | sudo pacman -S shfmt]],
}

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

local script_path = '/var/tmp/neovim_run_shell_script.sh'
os.remove(script_path)
create_user_command('RunShellScript', function(t)
  if shell_scripts[t.args] then
    local script = io.open(script_path, 'w')
    ---@diagnostic disable-next-line: need-check-nil
    script:write(shell_scripts[t.args])
    ---@diagnostic disable-next-line: need-check-nil
    script:close()
    vim.cmd.term(string.format('bash %s; rm %s', script_path, script_path))
  else
    vim.notify('No such shell script', vim.log.levels.ERROR)
  end
end, { nargs = 1 })

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

-- create_autocmd('FileType', {
--   pattern = { 'json', 'json5', 'jsonc', 'lsonc', 'markdown' },
--   callback = function()
--     vim.opt_local.shiftwidth = 2
--     vim.opt_local.softtabstop = 2
--     vim.opt_local.smarttab = true
--     vim.opt_local.expandtab = true
--   end,
-- })

-- create_autocmd('FileType', {
--   pattern = { 'lua' },
--   callback = function()
--     vim.opt_local.shiftwidth = 2
--     vim.opt_local.softtabstop = 2
--     vim.opt_local.smarttab = true
--     vim.opt_local.tabstop = 2
--   end,
-- })

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
    -- FIX: Need to fix. see L379
    -- vim.opt_local.wrap = true
    Utils.setup_markdown()
  end,
})

-- Events
---@diagnostic disable-next-line: param-type-mismatch
create_autocmd({ 'BufReadPost', 'BufWritePost', 'BufNewFile' }, {
  group = api.nvim_create_augroup('FileOpened', { clear = true }),
  pattern = '*',
  callback = function()
    ---@diagnostic disable-next-line: param-type-mismatch
    api.nvim_exec_autocmds('User', { pattern = 'FileOpened', modeline = false })
  end,
})

-- =============================================================================
-- Features
-- Tags: FEATURES
-- =============================================================================

-- Translate shell (trans)
---@param t string
---@param to string
local translate = function(t, to)
  vim.cmd.split()
  local text = t
  text = string.gsub(text, '"', [["'"'"]])
  text = string.gsub(text, '\\', '\\\\')
  text = string.gsub(text, '#', '\\#')
  vim.cmd.term('trans :' .. to .. ' "' .. text .. '"')

  keymap.set('n', 'q', '<cmd>bd<CR>', { buffer = true })
end

create_user_command('TranslateRegt', function(opts)
  local text = vim.fn.getreg('t')
  translate(text, opts.args)
end, {
  range = true,
  nargs = 1,
})

-- FIX: Need to fix
create_user_command('TranslateText', function(opts)
  local arg1 = vim.fn.split(opts.args, ' ')[2]
  local arg2 = vim.fn.split(opts.args, ' ')[1]
  translate(arg2, arg1)
end, { nargs = 1 })

keymap.set('v', '<leader>tr', '"ty<cmd>TranslateRegt zh<CR>', { noremap = true })

-- =============================================================================
-- Plugins
-- Tags: PLUG, PLUGIN, PLUGINS
-- =============================================================================

-- LAZYNVIM
local lazy_config = global_config.enabled_plugins and {
  install = { colorscheme = { 'gruvbox', 'habamax' } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  ui = {
    -- My font does not display the default icon properly
    -- Need Nerd Font
    icons = global_config.plugins_config.nerd_font_circle_and_square and {
      debug = ' ',
      loaded = '',
      not_loaded = '',
    } or {},
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'netrwPlugin',
      },
    },
  },
} or nil

local plugins = global_config.enabled_plugins and {

  -- COLORSCHEMES

  --- GRUVBOX-MATERIAL
  {
    'sainnhe/gruvbox-material',
    lazy = true,
    priority = 1000,
    config = function()
      local group_id = api.nvim_create_augroup('custom_highlights_gruvboxmaterial', {})

      create_autocmd('ColorScheme', {
        group = group_id,
        pattern = 'gruvbox-material',
        callback = function()
          local config = vim.fn['gruvbox_material#get_configuration']()
          local palette = vim.fn['gruvbox_material#get_palette'](config.background, config.foreground, config.colors_override)
          local set_hl = vim.fn['gruvbox_material#highlight']

          set_hl('TSString', palette.green, palette.none)
          set_hl('CursorLineNr', palette.orange, palette.none)
          set_hl('DiagnosticNumHlError', palette.red, palette.none, 'bold')
          set_hl('DiagnosticNumHlWarn', palette.yellow, palette.none, 'bold')
          set_hl('DiagnosticNumHlHint', palette.green, palette.none, 'bold')
          set_hl('DiagnosticNumHlInfo', palette.blue, palette.none, 'bold')
          set_hl('MiniFilesCursorLine', palette.none, palette.bg5)
          set_hl('WinBar', palette.fg1, palette.bg1)
        end,
      })

      -- vim.g.gruvbox_material_background = 'hard'
      -- vim.g.gruvbox_material_foreground = 'original'
      vim.g.gruvbox_material_disable_italic_comment = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
      vim.g.gruvbox_material_inlay_hints_background = 'dimmed'
      vim.g.gruvbox_material_current_word = 'underline'
      vim.g.gruvbox_material_better_performance = 1

      opt.background = 'dark'
      vim.cmd.colorscheme('gruvbox-material')
    end,
  },

  --- GRUVBOX
  {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('custom_highlights_gruvbox', {}),
        pattern = 'gruvbox',
        callback = function()
          local set_hl = vim.api.nvim_set_hl

          local foldcolumn_fg = Utils.get_hl('FoldColumn')
          set_hl(0, 'FoldColumn', { fg = foldcolumn_fg })
          set_hl(0, 'CursorLineFold', { fg = foldcolumn_fg, bg = Utils.get_hl('CursorLine', true) })

          set_hl(0, 'DiagnosticNumHlError', { fg = vim.o.background == 'dark' and '#fb4934' or '#9d0006', bold = true })
          set_hl(0, 'DiagnosticNumHlWarn', { fg = vim.o.background == 'dark' and '#fabd2f' or '#b57614', bold = true })
          set_hl(0, 'DiagnosticNumHlHint', { fg = vim.o.background == 'dark' and '#8ec07c' or '#427b58', bold = true })
          set_hl(0, 'DiagnosticNumHlInfo', { fg = vim.o.background == 'dark' and '#83a598' or '#076678', bold = true })

          -- Illuminate
          set_hl(0, 'IlluminatedWordText', { underline = true })
          set_hl(0, 'IlluminatedWordRead', { underline = true })
          set_hl(0, 'IlluminatedWordWrite', { underline = true })

          set_hl(0, 'GitsignsCurrentLineBlame', { fg = vim.o.background == 'dark' and '#7c6f64' or '#a89984' })
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

  -- MINI.FILES, FILES_MANAGER
  {
    'echasnovski/mini.files',
    dependencies = {
      'echasnovski/mini.icons',
    },
    keys = {
      ---@diagnostic disable-next-line: undefined-global
      { '<leader>e', function() MiniFiles.open() end },
      ---@diagnostic disable-next-line: undefined-global
      { '<leader>E', function() MiniFiles.open(api.nvim_buf_get_name(0)) end },
    },
    init = function()
      local mini_files_open_folder = function(path) require('mini.files').open(path) end
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
          close       = 'q',
          go_in       = '<S-CR>',
          go_in_plus  = '<CR>',
          go_out      = '<BS>',
          go_out_plus = '<S-BS>',
          mark_goto   = "'",
          mark_set    = 'm',
          reset       = '-',
          reveal_cwd  = '@',
          show_help   = 'g?',
          synchronize = '=',
          trim_left   = '<',
          trim_right  = '>',
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
    'echasnovski/mini.icons',
    lazy = true,
    opts = {
      style = global_config.plugins_config.ascii_mode and 'ascii' or 'glyph',
      file = {
        ['.keep'] = { glyph = global_config.plugins_config.ascii_mode and 'G' or '󰊢', hl = 'MiniIconsGrey' },
        ['devcontainer.json'] = { glyph = global_config.plugins_config.ascii_mode and 'D' or '', hl = 'MiniIconsAzure' },
      },
      filetype = {
        dotenv = { glyph = global_config.plugins_config.ascii_mode and 'D' or '', hl = 'MiniIconsYellow' },
        go = { glyph = global_config.plugins_config.ascii_mode and 'G' or '', hl = 'MiniIconsBlue' },
      },
    },
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },

  -- AUTOPAIRS
  {
    'windwp/nvim-autopairs',
    event = { 'VeryLazy' },
    opts = {},
  },

  -- MINI.SURROUND
  {
    'echasnovski/mini.surround',
    keys = {
      { 'sa', mode = { 'n', 'v' } }, 'sd', 'sf', 'sF', 'sh', 'sr', 'sn',
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

  -- FZFLUA
  {
    'ibhagwan/fzf-lua',
    dependencies = {
      'echasnovski/mini.icons',
      -- 'nvim-treesitter/nvim-treesitter-context',
    },
    cmd = 'FzfLua',
    keys = {
      { '<leader>ff', '<cmd>FzfLua files<CR>' },
      { '<leader>fr', '<cmd>FzfLua oldfiles<CR>' },
      { '<leader>fs', '<cmd>FzfLua live_grep<CR>' },
      { '<leader>fc', '<cmd>FzfLua grep<CR>' },
      { '<leader>fk', '<cmd>FzfLua keymaps<CR>' },
      -- { '<leader>fo', string.format('<cmd>FzfLua files cwd=%s<CR>', vim.fn.stdpath('config')) },
      { '<leader>fb', '<cmd>FzfLua buffers<CR>' },
      { '<leader>fw', '<cmd>FzfLua colorschemes<CR>' },
      { '<leader>fm', '<cmd>FzfLua manpages<CR>' },

      -- LSP
      { 'gr', '<cmd>FzfLua lsp_references<CR>', desc = 'Show LSP References' },
      { 'gd', '<cmd>FzfLua lsp_definitions<CR>', desc = 'Show LSP Definitions' },
      { 'gD', '<cmd>FzfLua lsp_declarations<CR>', desc = 'Show LSP Declarations' },
      { 'gI', '<cmd>FzfLua lsp_implementations<CR>', desc = 'Show LSP Implementations' },
      { 'gT', '<cmd>FzfLua lsp_typedefs<CR>', desc = 'Show LSP Type Definitions' },
      { '<leader>D', '<cmd>FzfLua lsp_document_diagnostics<CR>', desc = 'Show Buffer Diagnostics' },
    },
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require('lazy').load({ plugins = { 'fzf-lua' } })
        return vim.ui.select(...)
      end
    end,
    config = function()
      local fzf_lua = require('fzf-lua')
      fzf_lua.setup({
        winopts = {
          height = global_config.plugins_config.ivy_layout and 0.5 or 0.85,
          width = global_config.plugins_config.ivy_layout and 1 or 0.80,
          row = global_config.plugins_config.ivy_layout and 0.9999999 or 0.50,
          border = global_config.plugins_config.ivy_layout and { '─', '─', '', '', '', '', '', '' } or global_config.plugins_config.border,
          backdrop = 100,
          title_pos = global_config.plugins_config.ivy_layout and 'left' or 'center',
          preview = {
            border = global_config.plugins_config.ivy_layout and { '┬', '─', '', '', '', '', '', '│' } or global_config.plugins_config.border,
            title_pos = global_config.plugins_config.ivy_layout and 'left' or 'center',
          },
          on_create = function()
            keymap.set('t', '<C-e>', '<down>', { silent = true, buffer = true })
            keymap.set('t', '<C-u>', '<up>', { silent = true, buffer = true })
          end,
        },
        fzf_colors = true,
      })
      fzf_lua.register_ui_select()
    end,
  },

  -- TELESCOPE
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    cmd = 'Telescope',
    keys = function()
      local theme = global_config.plugins_config.ivy_layout and 'ivy' or ''
      return {
        { '<leader>fe', string.format('<cmd>Telescope file_browser theme=%s<CR>', theme) },
        { '<leader>fu', string.format('<cmd>Telescope undo theme=%s<CR>', theme) },
        { '<leader>fp', string.format('<cmd>Telescope neoclip theme=%s<CR>', theme) },
      }
    end,
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      { 'kkharji/sqlite.lua', module = 'sqlite' },

      -- Extensions
      dependencies = {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
      },
      'AckslD/nvim-neoclip.lua',
      'debugloop/telescope-undo.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      local get_borderchars_table = function()
        local b = global_config.plugins_config.border
        return {
          b[2],
          b[4],
          b[6],
          b[8],
          b[1],
          b[3],
          b[5],
          b[7],
        }
      end

      telescope.setup({
        defaults = {
          borderchars = {
            prompt = get_borderchars_table(),
            results = get_borderchars_table(),
            preview = get_borderchars_table(),
          },
          mappings = {
            i = {
              ['<C-u>'] = actions.move_selection_previous,
              ['<C-e>'] = actions.move_selection_next,
            },
          },
          winblend = vim.o.winblend,
        },
        pickers = {
          find_files = {
            theme = 'ivy',
          }
        },
        extensions = {
          file_browser = {
            hijack_netrw = true,
            hidden = { file_browser = true, folder_browser = true },
          },
          emoji = {
            action = function(emoji)
              -- argument emoji is a table.
              -- { name='', value='', cagegory='', description='' }

              vim.fn.setreg('+', emoji.value)
              print([[Press "+p or <M-p> to paste this emoji ]] .. emoji.value)

              -- insert emoji when picked
              -- api.nvim_put({ emoji.value }, 'c', false, true)
            end,
          },
        },
      })

      require('neoclip').setup({
        keys = {
          telescope = {
            i = {
              select = '<c-y>',
              paste = '<cr>',
              paste_behind = '<c-g>',
              replay = '<c-q>', -- replay a macro
              delete = '<c-d>', -- delete an entry
              edit = '<c-k>', -- edit an entry
              custom = {},
            },
          },
        },
      })

      local load_extension = telescope.load_extension

      load_extension('fzf')
      load_extension('neoclip')
      load_extension('undo')
      load_extension('file_browser')
    end,
  },

  -- NVIM-UFO
  {
    'kevinhwang91/nvim-ufo',
    enabled = true,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'kevinhwang91/promise-async',
    },
    keys = { 'z' },
    event = { 'BufAdd', 'User FileOpened' },
    config = function()
      keymap.set('n', 'zR', require('ufo').openAllFolds)
      keymap.set('n', 'zM', require('ufo').closeAllFolds)

      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (' < fold %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            newVirtText[#newVirtText + 1] = chunk
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            newVirtText[#newVirtText + 1] = { chunkText, hlGroup }
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        newVirtText[#newVirtText + 1] = { suffix, 'MoreMsg' }
        return newVirtText
      end

      require('ufo').setup({
        fold_virt_text_handler = handler,
        provider_selector = function()
          if require('nvim-treesitter.parsers').has_parser() then
            return { 'treesitter' }
          end
          return { 'treesitter', 'indent' }
        end,
      })

      ---@diagnostic disable-next-line: param-type-mismatch
      create_autocmd({ 'BufEnter', 'BufAdd', 'BufNew', 'BufNewFile', 'BufWinEnter' }, {
        callback = function()
          vim.cmd.UfoDisable()
          vim.cmd.UfoEnable()
        end,
      })
    end,
  },

  -- VIM-ILLUMINATE, WORD
  {
    'rrethy/vim-illuminate',
    event = 'User FileOpened',
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { 'lsp' },
      },
      filetypes_denylist = {
        'dirbuf',
        'dirvish',
        'fugitive',
        'starter',
        'telescopeprompt',
      },
    },
    config = function(_, opts)
      require('illuminate').configure(opts)

      local map = function(key, dir, buffer)
        keymap.set('n', key, function()
          require('illuminate')['goto_' .. dir .. '_reference'](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' reference', buffer = buffer })
      end

      map(']]', 'next')
      map('[[', 'prev')

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      create_autocmd('FileType', {
        pattern = '*',
        callback = function()
          local buffer = api.nvim_get_current_buf()
          map(']]', 'next', buffer)
          map('[[', 'prev', buffer)
        end,
      })

      create_autocmd('InsertLeave', {
        pattern = '*',
        callback = function()
          require('illuminate').resume()
        end,
      })

      create_autocmd('InsertEnter', {
        pattern = '*',
        callback = function()
          require('illuminate').pause()
        end,
      })
    end,
    keys = {
      { ']]', desc = 'next reference' },
      { '[[', desc = 'prev reference' },
    },
  },

  -- TODO-COMMENTS
  {
    'folke/todo-comments.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope', 'TodoFzfLua', 'TodoLocList', 'TodoQuickFix' },
    event = 'User FileOpened',
    opts = {
      keywords = {
        FIX = {
          icon = 'FX', -- icon used for the sign, and in search results
          color = 'error', -- can be a hex color, or a named color (see below)
          alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = 'TO', color = 'info' },
        HACK = { icon = 'HK', color = 'warning' },
        WARN = { icon = 'WN', color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = { icon = 'PF', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = 'NE', color = 'hint', alt = { 'INFO' } },
        TEST = { icon = 'TE', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
      },
    },
    -- stylua: ignore
    keys = {
      { ']c', function() require('todo-comments').jump_next() end, desc = 'Next Todo Comment' },
      { '[c', function() require('todo-comments').jump_prev() end, desc = 'Previous Todo Comment' },
      -- { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'Todo (Trouble)' },
      -- { '<leader>xT', '<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>', desc = 'Todo/Fix/Fixme (Trouble)' },
      { '<leader>ft', string.format('<cmd>TodoTelescope theme=%s<cr>', global_config.plugins_config.ivy_layout and 'ivy' or ''), desc = 'Todo' },
      { '<leader>fT', '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>', desc = 'Todo/Fix/Fixme' },
    },
  },

  -- DROPBAR, WINBAR
  {
    'Bekaboo/dropbar.nvim',
    event = 'User FileOpened',
    dependencies = {
      'echasnovski/mini.icons',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    keys = {
      { '<leader>;', function() require('dropbar.api').pick() end, desc = 'Pick symbols in winbar' },
      { '[;', function() require('dropbar.api').goto_context_start() end, desc = 'Go to start of current context' },
      { '];', function() require('dropbar.api').select_next_context() end, desc = 'Select next context' },
    },
  },

  -- TREESITTER
  {
    'nvim-treesitter/nvim-treesitter',
    enabled = true,
    version = false,
    event = { 'User FileOpened', 'BufAdd', 'VeryLazy' },
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
    keys = {
      -- context
      { '[c', function() require('treesitter-context').go_to_context() end, mode = 'n' },
    },
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      -- 'nvim-treesitter/nvim-treesitter-context',
      { 'HiPhish/rainbow-delimiters.nvim', submodules = false },
    },
    init = function(plugin)
      require('lazy.core.loader').add_to_rtp(plugin)
      require('nvim-treesitter.query_predicates')
    end,
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
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
        },
        -- auto_install = true,
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
        textobjects = {
          select = {
            disable = { 'dart' },
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['kf'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['kc'] = '@class.inner',
            }
          },
        },
      })

      -- HACK: temporary fix to ensure rainbow delimiters are highlighted in real-time
      create_autocmd('BufRead', {
        desc = 'Ensure treesitter is initialized???',
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      -- create_autocmd({ 'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter' }, {
      --   group = api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
      --   callback = function()
      --     if require("nvim-treesitter.parsers").has_parser() then
      --       opt.foldmethod = "expr"
      --       opt.foldexpr = "nvim_treesitter#foldexpr()"
      --     else
      --       opt.foldmethod = "syntax"
      --     end
      --   end,
      -- })
    end,
  },

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
    config = function() require('move').setup({ char = { enable = true } }) end
  },

  -- MULTI-CURSOR
  {
    'jake-stewart/multicursor.nvim',
    keys = function()
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
      hl(0, 'MultiCursorSign', { link = 'SignColumn'})
      hl(0, 'MultiCursorDisabledCursor', { link = 'Visual' })
      hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
      hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn'})
    end
  },

  -- FLASH
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      search = {
        exclude = {
          'notify',
          'cmp_menu',
          'noice',
          'flash_prompt',
          'bigfile',
          function(win)
            -- exclude non-focusable windows
            return not vim.api.nvim_win_get_config(win).focusable
          end,
        },
      },
      modes = {
        char = {
          enabled = false,
        },
      },
      -- labels = 'asdfghjklqwertyuiopzxcvbnm', -- Qwerty
      labels = 'arstdhneiqwfpgjluy;zxcvbkm', -- Colemak
      prompt = {
        prefix = { { ' Jump ', 'FlashPromptIcon' } },
      },
    },
    -- stylua: ignore
    keys = {
      { '<leader>/', function() require('flash').jump() end, mode = { 'n', 'x', 'o', 'v' }, desc = 'Flash' },
      { '<leader>?', function() require('flash').treesitter() end, mode = { 'n', 'x', 'o', 'v' }, desc = 'Flash Treesitter' },
      { '<leader>\\', function() require('flash').remote() end, mode = 'o', desc = 'Remote Flash' },
      { '<leader>|', function() require('flash').treesitter_search() end, mode = { 'o', 'x', 'v' }, desc = 'Treesitter Search' },
      { '<C-s>', function() require('flash').toggle() end, mode = 'c', desc = 'Toggle Flash Search' },
    },
  },

  -- MARKDOWN-PREVIEW
  {
    'iamcco/markdown-preview.nvim',
    lazy = false,
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
    dependencies = {
      'iamcco/markdown-preview.nvim',
    },
    cmd = {
      'RunCode',
      'RunFile',
      'RunProject',
      'RunClose',
      'CRFiletype',
      'CRProjects',
    },
    keys = {
      { '<leader>ra', function()
        vim.ui.input({prompt = 'Input Args: '}, function (args)
          if args ~= nil then
            vim.g.code_runner_run_args = args
          end
        end)
      end },
      { '<leader>R', function()
        vim.ui.input({prompt = 'Input Args: '}, function (args)
          if args ~= nil then
            vim.g.code_runner_run_args = args
            vim.cmd.RunCode()
            vim.g.code_runner_run_args = ''
          end
        end)
      end },
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
          size = 20
        },
        filetype = {
          java = {
            'cd $dir &&',
            'javac $fileName &&',
            'java $fileNameWithoutExt'
          },
          python = function() return 'python3 $file ' .. vim.g.code_runner_run_args end,
          dart = function() return 'dart run $file ' .. vim.g.code_runner_run_args end,
          go = function() return 'go run $file ' .. vim.g.code_runner_run_args end,
          lua = function() return 'lua $file ' .. vim.g.code_runner_run_args end,
          typescript = 'deno run',
          rust = {
            'cd $dir &&',
            'rustc $fileName &&',
            '$dir/$fileNameWithoutExt'
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

  -- INDENT-BLANKLINE
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = 'User FileOpened',
    config = function()
      require('ibl').setup({
        indent = {
          char = global_config.plugins_config.ascii_mode and '|' or '▏',
          tab_char = '>',
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

  -- LASTPLACE
  {
    'farmergreg/vim-lastplace',
    priority = 1000,
    config = function()
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
          always_update = true,
        },
      })
      vim.cmd.ColorizerReloadAllBuffers()
      vim.cmd.ColorizerToggle()
    end,
  },

  -- {
  --   'luukvbaal/statuscol.nvim',
  --   config = function ()
  --     local builtin = require("statuscol.builtin")
  --     require("statuscol").setup({
  --       relculright = true,
  --       segments = {
  --         -- { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
  --         {
  --           sign = { namespace = { "diagnostic/signs" }, maxwidth = 2, auto = true },
  --           click = "v:lua.ScSa"
  --         },
  --         { text = { builtin.lnumfunc }, click = "v:lua.ScLa", },
  --         {
  --           sign = { name = { ".*" }, maxwidth = 2, colwidth = 1, auto = true, wrap = true },
  --           click = "v:lua.ScSa"
  --         },
  --       }
  --     })
  --   end
  -- },

  -- SNACKS
  {
    'folke/snacks.nvim',
    lazy = false,
    priority = 1000,
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
            Snacks.util.wo(0, { foldmethod = 'manual', conceallevel = 0 })
            vim.b.minianimate_disable = true
            vim.cmd('IlluminatePauseBuf')
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(ctx.buf) then
                vim.bo[ctx.buf].syntax = ctx.ft
              end
            end)
          end,
        },
        quickfile = {},
        -- statuscolumn = {
        --   folds = {
        --     open = true,
        --     git_hl = true,
        --   },
        -- },

        styles = {
          notification = { border = 'single' },
          notification_history = {
            border = 'none',
            keys = {
              q = 'close',
              ['<ESC>'] = 'close',
            }
          },
        },
      })

      keymap.set('n', '<leader>rN', Snacks.rename.rename_file)
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
    end
  },

  -- TABNINE
  {
    'codota/tabnine-nvim',
    enabled = global_config.enabled_tabnine,
    build = './dl_binaries.sh',
    config = function()
      require('tabnine').setup({
        disable_auto_comment = true,
        accept_keymap = '<M-a>',
        dismiss_keymap = '<C-]>',
        debounce_ms = 800,
        suggestion_color = { gui = Utils.get_hl('Comment'), cterm = 244 },
        exclude_filetypes = { 'TelescopePrompt', 'NvimTree', 'fzf' },
        log_file_path = nil, -- absolute path to Tabnine log file
        ignore_certificate_errors = false,
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
          add          = { text = '+' },
          change       = { text = '~' },
          delete       = { text = '_' },
          topdelete    = { text = '-' },
          changedelete = { text = '~' },
          untracked    = { text = '?' },
        },
        signs_staged = {
          add          = { text = '+' },
          change       = { text = '~' },
          delete       = { text = '_' },
          topdelete    = { text = '-' },
          changedelete = { text = '~' },
          untracked    = { text = '?' },
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
    keys = {
      { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = 'Breakpoint Condition' },
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle Breakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = 'Run/Continue' },
      -- { '<leader>da', function() require('dap').continue({ before = get_args }) end, desc = 'Run with Args' },
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

      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

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

  -- FLUTTERTOOLS
  {
    'nvim-flutter/flutter-tools.nvim',
    cmd = {
      'FlutterRun',
      'FlutterDebug',
      'FlutterDevices',
      'FlutterEmulators',
      'FlutterReload',
      'FlutterRestart',
      'FlutterQuit',
      'FlutterAttach',
      'FlutterDetach',
      'FlutterOutlineToggle',
      'FlutterOutlineOpen',
      'FlutterDevTools',
      'FlutterDevToolsActivate',
      'FlutterCopyProfilerUrl',
      'FlutterLspRestart',
      'FlutterSuper',
      'FlutterReanalyze',
      'FlutterRename',
      'FlutterLogClear',
      'FlutterLogToggle',
    },
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('flutter-tools').setup({
        ui = {
          border = global_config.plugins_config.border,
        },
      })
    end,
  },

  -- LSPCONFIG
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'echasnovski/mini.icons',
      'lewis6991/gitsigns.nvim',
    },
    config = function()
      local lspconfig = require('lspconfig')
      local util = require('lspconfig.util')

      local if_nil = function(val, default)
        if val == nil then return default end
        return val
      end

      local capabilities = function(override)
        override = override or {}

        return {
          textDocument = {
            completion = {
              dynamicRegistration = if_nil(override.dynamicRegistration, false),
              completionItem = {
                snippetSupport = if_nil(override.snippetSupport, true),
                commitCharactersSupport = if_nil(override.commitCharactersSupport, true),
                deprecatedSupport = if_nil(override.deprecatedSupport, true),
                preselectSupport = if_nil(override.preselectSupport, true),
                tagSupport = if_nil(override.tagSupport, { valueSet = {
                    1, -- Deprecated
                  }
                }),
                insertReplaceSupport = if_nil(override.insertReplaceSupport, true),
                resolveSupport = if_nil(override.resolveSupport, {
                  properties = {
                    'documentation',
                    'detail',
                    'additionalTextEdits',
                    'sortText',
                    'filterText',
                    'insertText',
                    'textEdit',
                    'insertTextFormat',
                    'insertTextMode',
                  },
                }),
                insertTextModeSupport = if_nil(override.insertTextModeSupport, {
                  valueSet = {
                    1, -- asIs
                    2, -- adjustIndentation
                  }
                }),
                labelDetailsSupport = if_nil(override.labelDetailsSupport, true),
              },
              contextSupport = if_nil(override.snippetSupport, true),
              insertTextMode = if_nil(override.insertTextMode, 1),
              completionList = if_nil(override.completionList, {
                itemDefaults = {
                  'commitCharacters',
                  'editRange',
                  'insertTextFormat',
                  'insertTextMode',
                  'data',
                }
              })
            },
          },
        }
      end

      -- configure html server
      lspconfig['html'].setup({
        capabilities = capabilities(),
      })

      -- configure typescript server with plugin
      lspconfig['ts_ls'].setup({
        capabilities = capabilities(),
      })

      -- configure css server
      lspconfig['cssls'].setup({
        capabilities = capabilities(),
      })

      -- configure python server
      -- lspconfig['pyright'].setup({
      --   capabilities = capabilities(),
      --   on_attach = on_attach,
      -- })

      lspconfig['basedpyright'].setup({
        capabilities = capabilities(),
        settings = {
          basedpyright = {
            typeCheckingMode = 'standard',
          },
        },
      })

      -- configure lua server (with special settings)
      lspconfig['lua_ls'].setup({
        -- capabilities = capabilities(),
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
      lspconfig['gopls'].setup({
        capabilities = capabilities(),
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_dir = util.root_pattern('go.work', 'go.mod', '.git'),
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
          },
        },
      })

      -- configure Bash language server
      lspconfig['bashls'].setup({
        capabilities = capabilities(),
        cmd = { 'bash-language-server', 'start' },
      })

      lspconfig['fish_lsp'].setup({
        capabilities = capabilities(),
      })

      lspconfig['vimls'].setup({
        capabilities = capabilities(),
      })

      -- configure C and C++ ... language server
      lspconfig['clangd'].setup({
        capabilities = capabilities(),
        cmd = {
          'clangd',
          '--background-index',
        }
      })
      -- lspconfig['ccls'].setup({
      --   capabilities = capabilities(),
      --   filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'opencl' },
      --   root_dir = function(fname)
      --     return vim.loop.cwd() -- current working directory
      --   end,
      --   init_options = { cache = {
      --     -- directory = vim.env.XDG_CACHE_HOME .. '/ccls/',
      --     vim.fs.normalize '~/.cache/ccls' -- if on nvim 0.8 or higher
      --   } },
      -- })
    end,
  },

  -- LUASNIP
  {
    'L3MON4D3/LuaSnip',
    event = { 'InsertEnter', 'CmdlineEnter' },
    build = 'make install_jsregexp',
    config = function()
      local ls = require('luasnip')

      keymap.set({'i'}, '<C-k>', function() ls.expand() end, {silent = true})
      keymap.set({'i', 's'}, '<C-l>', function() ls.jump( 1) end, {silent = true})
      keymap.set({'i', 's'}, '<C-j>', function() ls.jump(-1) end, {silent = true})

      keymap.set({'i', 's'}, '<C-f>', function()
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

      -- nvim-cmp sources
      -- { 'Saghen/blink.compat', opts = { impersonate_nvim_cmp = true } },
      -- { 'tzachar/cmp-tabnine', enabled = enabled_tabnine, build = './install.sh' },
    },
    version = '*',
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()

      local opts = {
        appearance = {
          kind_icons = {
            Text = '󰉿',
            Method = '󰆧',
            Function = '󰊕',
            Constructor = '',
            Field = '󰜢',
            Variable = '󰀫',
            Class = '󰠱',
            Interface = '',
            Module = '',
            Property = '󰜢',
            Unit = '󰑭',
            Value = '󰎠',
            Enum = '',
            Keyword = '󰌋',
            Snippet = '',
            Color = '󰏘',
            File = '󰈙',
            Reference = '󰈇',
            Folder = '󰉋',
            EnumMember = '',
            Constant = '󰏿',
            Struct = '󰙅',
            Event = '',
            Operator = '󰆕',
            TypeParameter = '󰬛',
            Copilot = '',
          },
        },
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
              -- padding = { 0, 1 },
              treesitter = { 'lsp', 'copilot', 'cmp_tabnine', 'snippets' },
              columns = {
                -- { 'kind_icon' },
                -- { 'label', 'label_description', gap = 1 },
                { 'label' },
                global_config.plugins_config.ascii_mode and { 'kind' } or { 'kind_icon', 'kind', gap = 1 },
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
                -- kind_icon = {
                --   ellipsis = false,
                --   text = function(ctx)
                --     return ' ' .. ctx.kind_icon .. ' '
                --   end,
                --   highlight = function(ctx)
                --     ---@diagnostic disable-next-line: ambiguity-1
                --     return require('blink.cmp.completion.windows.render.tailwind').get_hl(ctx)
                --       or 'BlinkCmpKind' .. ctx.kind
                --   end,
                -- },
                source_name = {
                  width = { max = 30 },
                  text = function(ctx)
                    return '[' .. ctx.source_name .. ']'
                  end,
                  highlight = 'BlinkCmpSource',
                },
              },
            },
            -- border = 'single',
            winblend = vim.o.pumblend,
            max_height = 30,
          },
        },
        snippets = { preset = 'luasnip' },
        sources = {
          default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer',
            global_config.enabled_copilot and 'copilot' or nil,
            -- enabled_tabnine and 'cmp_tabnine' or nil,
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
        opts.sources.provides.copilot = {
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

      -- if global_config.enabled_tabnine then
      --   opts.sources.providers.cmp_tabnine = {
      --     name = 'cmp_tabnine',
      --     module = 'blink.compat.source',
      --     score_offset = -3,
      --   }
      -- end

      require('blink.cmp').setup(opts)
    end,
  },

} or nil

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

  opt.laststatus = 2
  opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
  opt.foldlevelstart = 99
  opt.foldenable = true

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
