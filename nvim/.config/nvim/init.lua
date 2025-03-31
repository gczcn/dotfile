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
--   rust - nightly version for blink.cmp
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
-- Run :RunShellScripgt <install|update>_deps_<package_manager>
-- Supported package managers:
--   pacman and yay
--   homebrew
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
---@field edge_comments_italic boolean
---@field edge_conditionals_italic boolean
---@field edge_italic boolean
---@field gruvbox_comments_italic boolean
---@field gruvbox_folds_italic boolean
---@field gruvbox_conditionals_italic boolean
---@field gruvbox_constant_builtin_italic boolean
---@field gruvbox_types_italic boolean
---@field ivy_layout boolean
---@field noice_classic_cmdline boolean

---@class StatusColumnConfig
---@field enabled boolean
---@field indent boolean
---@field indent_fold_char string
---@field indent_fold_end string
---@field show_fold_end boolean
---@field fold_end_char string
---@field foldcolumn_rightsplit_char string
---@field foldcolumn_leftsplit_char string

---@class global_config
---@field middle_row_of_keyboard string[]
---@field remove_padding_around_neovim_instance boolean
---@field auto_toggle_relativenumber boolean
---@field enabled_plugins boolean
---@field enabled_copilot boolean
---@field enabled_tabnine boolean
---@field statuscolumn StatusColumnConfig
---@field plugins_config PluginsConfig
local global_config = {
	-- 0, 1, 2, ..., 9
	middle_row_of_keyboard = { 'o', 'a', 'r', 's', 't', 'd', 'h', 'n', 'e', 'i' }, -- Colemak
	remove_padding_around_neovim_instance = false,
	auto_toggle_relativenumber = false, -- WARN: There are performance issues, such as slowing down macro functions
	enabled_plugins = true,
	enabled_copilot = false,
	enabled_tabnine = false,
	statuscolumn = {
		enabled = true,
		indent = false,
		indent_fold_char = '│',
		indent_fold_end = '└',
		show_fold_end = true,
		fold_end_char = '^',
		foldcolumn_rightsplit_char = ' ',
		foldcolumn_leftsplit_char = ' ',
	},
	plugins_config = {
		border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
		nerd_font_circle_and_square = false,
		ascii_mode = false,
		edge_comments_italic = false,
		edge_conditionals_italic = false,
		edge_italic = false,
		gruvbox_comments_italic = false,
		gruvbox_folds_italic = false,
		gruvbox_conditionals_italic = false,
		gruvbox_constant_builtin_italic = false,
		gruvbox_types_italic = false,
		ivy_layout = false,
		noice_classic_cmdline = false,
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

---@param t any[]
---@param v any
---@return integer|nil
Utils.table_indexof = function(t, v)
	if type(t) == 'table' then
		for i = 1, #t do
			if v == t[i] then
				return i
			end
		end
	end

	return nil
end

---@param k string
Utils.do_sth_with_middle_row_of_keyboard = function(k)
	vim.o.relativenumber = true
	vim.cmd.redraw()
	---@type number?
	local char
	local index
	local count = ''
	while true do
		---@diagnostic disable-next-line: param-type-mismatch
		char = tonumber(vim.fn.getchar())
		if char == 27 then goto stop end
		if char == 32 then goto continue end
		index = Utils.table_indexof(global_config.middle_row_of_keyboard, tostring(vim.fn.nr2char(char or 0)))
		index = index and index - 1 or nil
		if not index then goto stop end
		count = count .. tostring(index)
	end
	---@diagnostic disable-next-line: unreachable-code
	::continue::
	api.nvim_feedkeys(count .. k, 'n', false)
	::stop::
	vim.o.relativenumber = false
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

-- Get icon from file name or file type
-- Need nvim-web-devicons or mini.icons
---@param filename string?
---@param filetype string?
---@return string|nil, string|nil
Utils.get_file_icon = function(filename, filetype)
	local icon_filetype, color_filetype = require('nvim-web-devicons').get_icon_color_by_filetype(filetype or '')
	local icon_filename, color_filename = require('nvim-web-devicons').get_icon_color(filename or '')
	if icon_filename then return icon_filename, color_filename end
	return icon_filetype, color_filetype
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
keymap.set('v', 'kr', '`[`]', keymaps_opts)

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

-- Buffer
keymap.set('n', '<leader>bd', '<cmd>bd<CR>', keymaps_opts)

-- Cursor
keymap.set({ 'n', 'v', 'o' }, "<leader>'", function() Utils.do_sth_with_middle_row_of_keyboard('j') end)
keymap.set({ 'n', 'v', 'o' }, "<leader>[", function() Utils.do_sth_with_middle_row_of_keyboard('k') end)

-- Other
--- Toggle background [ dark | light ]
keymap.set({ 'n', 'v' }, '<F5>', function()
	opt.background = vim.o.background == 'dark' and 'light' or 'dark'
end, keymaps_opts)
keymap.set('n', '<leader>tc', function()
	opt.cursorcolumn = not vim.o.cursorcolumn
end, keymaps_opts)
keymap.set({ 'n', 'v' }, 'U', 'K', keymaps_opts)
keymap.set('n', '<leader>l', '<cmd>noh<CR>', keymaps_opts)
keymap.set('n', '<leader>fn', '<cmd>messages<CR>', keymaps_opts)
keymap.set('n', '<leader>oo', '<cmd>e ' .. vim.fn.stdpath('config') .. '/init.lua<CR>')
keymap.set('n', '<leader>gg', function() Utils.goto_github(vim.fn.expand('<cfile>')) end)
keymap.set('n', '<leader><leader>', '<cmd>lua vim.diagnostic.config({virtual_lines=not vim.diagnostic.config().virtual_lines})<CR>')

-- =============================================================================
-- Options
-- Tags: OPT, OPTS, OPTION, OPTIONS
-- =============================================================================

vim.g.encoding = 'UTF-8'

opt.autowrite = true
opt.breakindent = true -- Wrap indent to match line start
-- opt.cmdheight = 0 -- Use noice.nvim plugin, no need to display cmdline
-- opt.colorcolumn = '80' -- Line number reminder
opt.conceallevel = 2 -- Hide * markup for hold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.copyindent = true -- Copy the previous indentation on autoindenting
-- opt.cursorcolumn = true -- Highlight the text column of the cursor
opt.cursorline = true -- Highlight the text line of the cursor
opt.expandtab = false
opt.fileencoding = 'utf-8' -- File content encoding for the buffer
opt.foldcolumn = '1'
opt.guicursor = vim.fn.has('nvim-0.11') == 1
	and 'n-v-sm:block,i-c-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor'
	or 'n-v-sm:block,i-c-ci-ve:ver25,r-cr-o:hor20'
-- opt.fillchars = { foldopen = '▂', foldclose = '▐' }
opt.ignorecase = true -- Ignore case
opt.list = true -- Show some hidden characters
opt.listchars = { tab = '> ', trail = '-', extends = '>', precedes = '<', nbsp = '+' }
opt.number = true
opt.pumblend = 10
opt.pumheight = 30

-- opt.relativenumber = true
opt.scrolloff = 8 -- Lines of context
opt.shiftround = true -- Round indent
opt.shiftwidth = 8 -- Number of space inserted for indentation
opt.showmode = false -- No display mode
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = 'auto'
opt.smartcase = true -- Case sensitive searching
opt.smartindent = true -- Insert indents automatically
opt.smoothscroll = true
-- opt.softtabstop = 8
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.tabstop = 8 -- Number of spaces tabs count for
opt.termguicolors = true -- Enable true colors
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
-- opt.virtualedit = 'block' -- Allow cursor to move where there is no text in visual block mode
opt.winblend = 10
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

if not global_config.enabled_plugins then
	vim.cmd.colorscheme('habamax')
	local set_hl = api.nvim_set_hl

	-- Custom Status Column (Tags: column, statuscolumn, status_column)
	set_hl(0, 'StatusColumnFold', { link = 'FoldColumn' })
	set_hl(0, 'StatusColumnFoldOpen', { link = 'FoldColumn' })
	set_hl(0, 'StatusColumnFoldClose', { link = 'Normal' })
	set_hl(0, 'StatusColumnFoldEnd', { link = 'FoldColumn' })
	set_hl(0, 'StatusColumnFoldCursorLine', { link = 'FoldColumn' })
	set_hl(0, 'StatusColumnFoldOpenCursorLine', { link = 'FoldColumn' })
	set_hl(0, 'StatusColumnFoldCloseCursorLine', { link = 'Normal' })
	set_hl(0, 'StatusColumnFoldEndCursorLine', { link = 'FoldColumn' })
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
	}
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

# Code Runner
brew install gcc

# Language servers
brew install llvm  # C and C++
brew install typescript-language-server  # Typescript
# brew install pyright  # Python
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
brew install shfmt

# Rust Nightly (for blink.cmp)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly]],
	update_deps_brew = [[
#!/usr/bin/env bash
brew update

brew upgrade ripgrep
brew upgrade fd
brew upgrade node
brew upgrade npm
brew upgrade fzf

# Code Runner
brew upgrade gcc

# Language servers
brew upgrade llvm
brew upgrade typescript-language-server
# brew upgrade pyright
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
brew upgrade shfmt

# Rust Nightly (for blink.cmp)
rustup update nightly]],
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
# yes | sudo pacman -S pyright
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
yes | sudo pacman -S shfmt

# Rust Nightly (for blink.cmp)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly]],
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
# yes | sudo pacman -S pyright
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
yes | sudo pacman -S shfmt

# Rust Nightly (for blink.cmp)
rustup update nightly]],
}

-- =============================================================================
-- Commands
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

-- https://www.reddit.com/r/neovim/comments/1ehidxy/you_can_remove_padding_around_neovim_instance/
if global_config.remove_padding_around_neovim_instance then
	local id = api.nvim_create_augroup('remove_padding_around_neovim_instance', {})
	create_autocmd({ 'UIEnter', 'ColorScheme' }, {
		group = id,
		callback = function()
			local normal = api.nvim_get_hl(0, { name = 'Normal' })
			if not normal.bg then return end
			io.write(string.format('\027Ptmux;\027\027]11;#%06x\007\027\\', normal.bg))
			io.write(string.format('\027]11;#%06x\027\\', normal.bg))
		end,
	})

	create_autocmd({ 'UILeave', 'VimLeave' }, {
		group = id,
		callback = function()
			io.write('\027Ptmux;\027\027]111;\007\027\\')
			io.write('\027]111\027\\')
		end,
	})
end

-- Line breaks are not automatically commented
create_autocmd('FileType', {
	pattern = '*',
	callback = function()
		vim.cmd('setlocal formatoptions-=c formatoptions-=r formatoptions-=o')
	end,
})

-- Highlight when copying
create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- https://github.com/sitiom/nvim-numbertoggle/blob/main/plugin/numbertoggle.lua
if global_config.auto_toggle_relativenumber then
	local numbertoggleaugroup = api.nvim_create_augroup("numbertoggle", {})

	create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
		pattern = '*',
		group = numbertoggleaugroup,
		callback = function()
			if vim.o.nu and api.nvim_get_mode().mode ~= 'i' then
				opt.relativenumber = true
			end
		end,
	})

	create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
		pattern = '*',
		group = numbertoggleaugroup,
		callback = function()
			if vim.o.nu then
				opt.relativenumber = false
				vim.cmd('redraw')
			end
		end,
	})
end

create_autocmd('FileType', {
	pattern = { 'json', 'json5', 'jsonc', 'lsonc', 'markdown' },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.smarttab = true
		vim.opt_local.expandtab = true
	end,
})

-- create_autocmd('FileType', {
-- 	pattern = { 'lua' },
-- 	callback = function()
-- 		vim.opt_local.shiftwidth = 2
-- 		vim.opt_local.softtabstop = 2
-- 		vim.opt_local.smarttab = true
-- 		vim.opt_local.tabstop = 2
-- 	end,
-- })

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

-- Events

create_autocmd({ 'BufReadPost', 'BufWritePost', 'BufNewFile' }, {
	group = api.nvim_create_augroup('FileOpened', { clear = true }),
	pattern = '*',
	callback = function()
		api.nvim_exec_autocmds('User', { pattern = 'FileOpened', modeline = false })
	end,
})

-- =============================================================================
-- PopUp Menu
-- Tags: POPUP, POPUPMENU
-- =============================================================================
if global_config.enabled_plugins then
	vim.cmd([[
amenu disable PopUp.How-to\ disable\ mouse
anoremenu PopUp.References <cmd>FzfLua lsp_references<CR>
anoremenu PopUp.Declarations <cmd>FzfLua lsp_declarations<CR>
anoremenu PopUp.Definitions <cmd>FzfLua lsp_definitions<CR>
anoremenu PopUp.Implementations <cmd>FzfLua lsp_implementations<CR>
anoremenu PopUp.TypeDefs <cmd>FzfLua lsp_typedefs<CR>]])
end

-- =============================================================================
-- Status Column
-- The following highlight groups need to be set manually
--   StatusColumnFold
--   StatusColumnFoldOpen
--   StatusColumnFoldClose
--   StatusColumnFoldEnd
--   StatusColumnFoldCursorLine
--   StatusColumnFoldOpenCursorLine
--   StatusColumnFoldCloseCursorLine
--   StatusColumnFoldEndCursorLine
--
-- Tags: COLUMN, STATUSCOLUMN, STATUS_COLUMN
-- =============================================================================

if global_config.statuscolumn.enabled then
	_G.GetStatusColumn = function()
		local text = ''

		---@return string
		local cursorline_hl = function()
			if vim.v.relnum == 0 then
				return '%#CursorLineNr#'
			end
			return ''
		end

		---@return string
		local get_line_number = function()
			return api.nvim_win_call(vim.g.statusline_winid, function()
				return '%=' .. (((vim.o.number or vim.o.relativenumber) and vim.v.virtnum == 0) and
					(vim.fn.has('nvim-0.11') == 1 and '%l' or (vim.v.relnum == 0 and (vim.o.number and '%l' or '%r') or (vim.o.relativenumber and '%r' or '%l'))) or '')
			end)
		end

		---@param show_indent_symbol boolean|nil
		---@param show_fold_end boolean|nil
		---@return string
		local get_fold = function(show_indent_symbol, show_fold_end)
			return api.nvim_win_call(vim.g.statusline_winid, function()
				---@type integer
				---@diagnostic disable-next-line
				local foldcolumn = tonumber(vim.o.foldcolumn)
				if foldcolumn == 0 then return '' end

				local foldtext = ''

				local ts_foldexpr = tostring(vim.treesitter.foldexpr(vim.v.lnum))
				local ts_foldexpr_after = tostring(vim.treesitter.foldexpr(vim.v.lnum + 1))
				---@type integer
				local foldlevel = vim.fn.foldlevel(vim.v.lnum)
				local foldlevel_before = vim.fn.foldlevel(vim.v.lnum - 1)
				local foldlevel_after = vim.fn.foldlevel(vim.v.lnum + 1)
				local foldclosed = vim.fn.foldclosed(vim.v.lnum)
				local foldopen_char = opt.fillchars:get().foldopen or '-'
				local foldclose_char = opt.fillchars:get().foldopen or '+'

				---@param current_chars integer
				---@return string
				local get_other_chars = function(current_chars)
					return string.rep(' ', foldcolumn - current_chars)
				end

				---@param n integer
				---@return integer
				local get_index = function(n)
					return n < foldcolumn and n or foldcolumn
				end

				---@param hl string
				---@param s string
				---@return string
				local get_hl_text = function(hl, s)
					return string.format('%%#%s#%s', 'StatusColumn' .. hl .. (vim.v.relnum == 0 and 'CursorLine' or ''), s)
				end

				foldtext = foldtext
					.. (foldlevel ~= 0 and (get_hl_text('Fold', string.rep(show_indent_symbol and global_config.statuscolumn.indent_fold_char or ' ', get_index(foldlevel) - 1))
					.. ((foldclosed ~= -1 and foldclosed == vim.v.lnum) and get_hl_text('FoldClose', foldclose_char)
						or ((foldlevel > foldlevel_before or ts_foldexpr:sub(1, 1) == '>') and get_hl_text('FoldOpen', foldopen_char)
						or (((show_fold_end or show_indent_symbol) and ((ts_foldexpr_after:sub(1, 1) == '>' and foldlevel == foldlevel_after) or foldlevel > foldlevel_after))
						and (get_hl_text(show_fold_end and 'FoldEnd' or 'Fold', show_fold_end and global_config.statuscolumn.fold_end_char or global_config.statuscolumn.indent_fold_end))
						or (get_hl_text('Fold', show_indent_symbol and global_config.statuscolumn.indent_fold_char or ' ')))))) or '')
				return global_config.statuscolumn.foldcolumn_leftsplit_char .. foldtext .. get_other_chars(get_index(foldlevel)) .. global_config.statuscolumn.foldcolumn_rightsplit_char
			end)
		end

		text = table.concat({
			'%s', -- SignColumn
			cursorline_hl(),
			get_line_number(),
			get_fold(global_config.statuscolumn.indent, global_config.statuscolumn.show_fold_end),
		})

		return text
	end

	opt.statuscolumn = '%!v:lua.GetStatusColumn()'
end

-- =============================================================================
-- Gui
-- Tags: GUI
-- =============================================================================

local gui_font = 'FiraCode Nerd Font Mono'
local gui_font_size = 11.2

---@param n number
local gui_change_font_size = function(n)
	gui_font_size = gui_font_size + n
	opt.guifont = gui_font .. ':h' .. tostring(gui_font_size)
	vim.notify(tostring(gui_font_size))
end

opt.guifont = gui_font .. ':h' .. gui_font_size

keymap.set('n', '<C-=>', function()
	gui_change_font_size(0.1)
end)
keymap.set('n', '<C-->', function()
	gui_change_font_size(-0.1)
end)

-- ========== NEOVIDE ==========
if vim.g.neovide then
	local neovide_transparency = 1

	---@param n number
	local neovide_change_transparency = function(n)
		if neovide_transparency + n <= 1 and neovide_transparency + n >= 0 then
			neovide_transparency = neovide_transparency + n
			vim.g.neovide_transparency = neovide_transparency
			print(neovide_transparency)
		else
			print('transparency out of range (' .. neovide_transparency .. ')')
		end
	end

	vim.o.pumblend = 20
	vim.o.winblend = 20

	vim.g.neovide_floating_blur_amount_x = 1.5
	vim.g.neovide_floating_blur_amount_y = 1.5
	vim.g.neovide_scroll_animation_length = 0.3
	vim.g.neovide_hide_mouse_when_typing = true
	vim.g.neovide_unlink_border_highlights = true
	vim.g.neovide_confirm_quit = true
	vim.g.neovide_cursor_animate_command_line = true
	vim.g.neovide_cursor_unfocused_outline_width = 0.1
	vim.g.neovide_remember_window_size = true
	vim.g.neovide_input_macos_option_key_is_meta = 'only_left'
	vim.g.neovide_transparency = neovide_transparency

	keymap.set('n', '<C-+>', function()
		neovide_change_transparency(0.1)
	end)
	keymap.set('n', '<C-_>', function()
		neovide_change_transparency(-0.1)
	end)
end

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
	install = { colorscheme = { 'gruvbox', 'catppuccin', 'habamax', 'edge' } },
	checker = { enabled = true },
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
	--- EDGE
	{
		'sainnhe/edge',
		lazy = true,
		priority = 1000,
		config = function()
			create_autocmd('ColorScheme', {
				group = vim.api.nvim_create_augroup('custom_highlights_edge', {}),
				pattern = 'edge',
				callback = function()
					local config = vim.fn['edge#get_configuration']()
					local palette = vim.fn['edge#get_palette'](config.style, config.dim_foreground, config.colors_override)
					local set_hl = vim.fn['edge#highlight']

					set_hl('Visual', palette.none, palette.bg4)
					set_hl('VisualNOS', palette.none, palette.bg4)
					set_hl('Directory', palette.green, palette.none, 'bold')
					set_hl('CursorLineNr', palette.bg_grey, vim.o.cursorline and palette.bg1 or palette.none)
					set_hl('CursorLineSign', palette.bg_grey, vim.o.cursorline and palette.bg1 or palette.none)
					set_hl('WinBar', palette.fg, palette.bg2)
					if global_config.plugins_config.edge_conditionals_italic then
						set_hl('Conditional', palette.purple, palette.none, 'italic')
						set_hl('TSConditional', palette.purple, palette.none, 'italic')
					end

					-- Custom Status Column (Tags: column, statuscolumn, status_column)
					set_hl('StatusColumnFold', palette.bg4, palette.bg0)
					set_hl('StatusColumnFoldOpen', palette.grey_dim, palette.bg0)
					set_hl('StatusColumnFoldClose', palette.blue, palette.bg1)
					set_hl('StatusColumnFoldEnd', palette.grey_dim, palette.bg0)
					set_hl('StatusColumnFoldCursorLine', palette.bg4, vim.o.cursorline and palette.bg1 or palette.none)
					set_hl('StatusColumnFoldOpenCursorLine', palette.grey_dim, vim.o.cursorline and palette.bg1 or palette.none)
					set_hl('StatusColumnFoldCloseCursorLine', palette.blue, vim.o.cursorline and palette.bg1 or palette.none)
					set_hl('StatusColumnFoldEndCursorLine', palette.grey_dim, vim.o.cursorline and palette.bg1 or palette.none)

					-- Custom
					set_hl('DiagnosticNumHlError', palette.red, palette.none, 'bold')
					set_hl('DiagnosticNumHlWarn', palette.yellow, palette.none, 'bold')
					set_hl('DiagnosticNumHlHint', palette.green, palette.none, 'bold')
					set_hl('DiagnosticNumHlInfo', palette.blue, palette.none, 'bold')

					set_hl('MiniFilesCursorLine', palette.none, palette.bg4)
				end,
			})

			opt.background = 'dark'
			vim.g.edge_style = 'aura'
			vim.g.edge_disable_italic_comment = global_config.plugins_config.edge_comments_italic and 0 or 1
			vim.g.edge_enable_italic = global_config.plugins_config.edge_italic and 1 or 0
			vim.g.edge_diagnostic_virtual_text = 'highlighted'
			vim.g.edge_inlay_hints_background = 'dimmed'
			vim.g.edge_better_performance = 1

			vim.cmd.colorscheme('edge')
		end,
	},

	--- GRUVBOX
	{
		'ellisonleao/gruvbox.nvim',
		lazy = false,
		priority = 1000,
		config = function()
			create_autocmd('ColorScheme', {
				group = api.nvim_create_augroup('custom_highlights_gruvbox', {}),
				pattern = 'gruvbox',
				callback = function()
					local p = require('gruvbox').palette
					local set_hl = api.nvim_set_hl
					local colors = vim.o.background == 'dark' and {
						bg0 = p.dark0,
						bg1 = p.dark1,
						bg2 = p.dark2,
						bg3 = p.dark3,
						bg4 = p.dark4,
						fg0 = p.light0,
						fg1 = p.light1,
						fg2 = p.light2,
						fg3 = p.light3,
						fg4 = p.light4,
						red = p.bright_red,
						green = p.bright_green,
						yellow = p.bright_yellow,
						blue = p.bright_blue,
						purple = p.bright_purple,
						aqua = p.bright_aqua,
						orange = p.bright_orange,
						neutral_red = p.neutral_red,
						neutral_green = p.neutral_green,
						neutral_yellow = p.neutral_yellow,
						neutral_blue = p.neutral_blue,
						neutral_purple = p.neutral_purple,
						neutral_aqua = p.neutral_aqua,
						dark_red = p.dark_red,
						dark_green = p.dark_green,
						dark_aqua = p.dark_aqua,
						gray = p.gray,
					} or {
						bg0 = p.light0,
						bg1 = p.light1,
						bg2 = p.light2,
						bg3 = p.light3,
						bg4 = p.light4,
						fg0 = p.dark0,
						fg1 = p.dark1,
						fg2 = p.dark2,
						fg3 = p.dark3,
						fg4 = p.dark4,
						red = p.faded_red,
						green = p.faded_green,
						yellow = p.faded_yellow,
						blue = p.faded_blue,
						purple = p.faded_purple,
						aqua = p.faded_aqua,
						orange = p.faded_orange,
						neutral_red = p.neutral_red,
						neutral_green = p.neutral_green,
						neutral_yellow = p.neutral_yellow,
						neutral_blue = p.neutral_blue,
						neutral_purple = p.neutral_purple,
						neutral_aqua = p.neutral_aqua,
						dark_red = p.light_red,
						dark_green = p.light_green,
						dark_aqua = p.light_aqua,
						gray = p.gray,
					}
					set_hl(0, 'CursorLineSign', { bg = colors.bg1 })
					if global_config.plugins_config.gruvbox_conditionals_italic then set_hl(0, 'Conditional', { fg = colors.red, italic = true }) end
					if global_config.plugins_config.gruvbox_constant_builtin_italic then set_hl(0, '@constant.builtin', { fg = colors.orange, italic = true }) end
					if global_config.plugins_config.gruvbox_types_italic then set_hl(0, 'Type', { fg = colors.yellow, italic = true }) set_hl(0, 'dosiniLabel', { fg = colors.yellow }) end

					-- Custom
					set_hl(0, 'DiagnosticNumHlError', { fg = colors.red, bold = true })
					set_hl(0, 'DiagnosticNumHlWarn', { fg = colors.yellow, bold = true })
					set_hl(0, 'DiagnosticNumHlHint', { fg = colors.aqua, bold = true })
					set_hl(0, 'DiagnosticNumHlInfo', { fg = colors.blue, bold = true })
					set_hl(0, 'SignColumn', { bg = Utils.get_hl('Normal', true) })

					-- Custom Status Column (Tags: column, statuscolumn, status_column)
					set_hl(0, 'StatusColumnFold', { fg = colors.bg2 })
					set_hl(0, 'StatusColumnFoldOpen', { fg = colors.gray })
					set_hl(0, 'StatusColumnFoldClose', { fg = colors.yellow, bg = Utils.get_hl('Folded', true) })
					set_hl(0, 'StatusColumnFoldEnd', { fg = colors.gray })
					set_hl(0, 'StatusColumnFoldCursorLine', { fg = colors.bg2, bg = Utils.get_hl('CursorLine', true) })
					set_hl(0, 'StatusColumnFoldOpenCursorLine', { fg = colors.gray, bg = Utils.get_hl('CursorLine', true) })
					set_hl(0, 'StatusColumnFoldCloseCursorLine', { fg = colors.yellow, bg = Utils.get_hl('CursorLine', true) })
					set_hl(0, 'StatusColumnFoldEndCursorLine', { fg = colors.gray, bg = Utils.get_hl('CursorLine', true) })

					set_hl(0, 'NoiceCmdlineIcon', { fg = colors.orange })
					set_hl(0, 'NoiceCmdlineIconLua', { fg = colors.blue })
					set_hl(0, 'NoiceCmdlineIconHelp', { fg = colors.red })

					set_hl(0, 'FzfLuaHeaderText', { fg = colors.red })
					set_hl(0, 'FzfLuaHeaderBind', { fg = colors.orange })
					set_hl(0, 'FzfLuaPathColNr', { fg = colors.blue })
					set_hl(0, 'FzfLuaPathLineNr', { fg = colors.aqua })
					set_hl(0, 'FzfLuaLiveSym', { fg = colors.red })
					set_hl(0, 'FzfLuaBufNr', { fg = colors.fg1 })
					set_hl(0, 'FzfLuaBufFlagCur', { fg = colors.red })
					set_hl(0, 'FzfLuaBufFlagAlt', { fg = colors.blue })
					set_hl(0, 'FzfLuaTabTitle', { fg = colors.blue })
					set_hl(0, 'FzfLuaTabMarker', { fg = colors.fg0 })

					set_hl(0, 'TodoBgTEST', { fg = colors.blue, bold = true })
					set_hl(0, 'TodoBgHACK', { fg = colors.yellow, bold = true })
					set_hl(0, 'TodoBgNOTE', { fg = colors.aqua, bold = true })
					set_hl(0, 'TodoBgTODO', { fg = colors.blue, bold = true })
					set_hl(0, 'TodoBgFIX', { fg = colors.red, bold = true })
					set_hl(0, 'TodoBgPERF', { fg = colors.blue, bold = true })
					set_hl(0, 'TodoBgWARN', { fg = colors.yellow, bold = true })

					set_hl(0, 'FlashLabel', { bg = colors.red, fg = colors.bg0, bold = true })

					set_hl(0, 'BlinkCmpKindClass', { fg = colors.yellow })
					set_hl(0, 'BlinkCmpKindColor', { fg = colors.purple })
					set_hl(0, 'BlinkCmpKindConstant', { fg = colors.orange })
					set_hl(0, 'BlinkCmpKindConstructor', { fg = colors.yellow })
					set_hl(0, 'BlinkCmpKindEnum', { fg = colors.yellow })
					set_hl(0, 'BlinkCmpKindEnumMember', { fg = colors.aqua })
					set_hl(0, 'BlinkCmpKindEvent', { fg = colors.purple })
					set_hl(0, 'BlinkCmpKindField', { fg = colors.blue })
					set_hl(0, 'BlinkCmpKindFile', { fg = colors.blue })
					set_hl(0, 'BlinkCmpKindFolder', { fg = colors.blue })
					set_hl(0, 'BlinkCmpKindFunction', { fg = colors.blue })
					set_hl(0, 'BlinkCmpKindInterface', { fg = colors.yellow })
					set_hl(0, 'BlinkCmpKindKeyword', { fg = colors.purple })
					set_hl(0, 'BlinkCmpKindMethod', { fg = colors.blue })
					set_hl(0, 'BlinkCmpKindModule', { fg = colors.blue })
					set_hl(0, 'BlinkCmpKindOperator', { fg = colors.yellow })
					set_hl(0, 'BlinkCmpKindProperty', { fg = colors.blue })
					set_hl(0, 'BlinkCmpKindReference', { fg = colors.purple })
					set_hl(0, 'BlinkCmpKindSnippet', { fg = colors.green })
					set_hl(0, 'BlinkCmpKindStruct', { fg = colors.yellow })
					set_hl(0, 'BlinkCmpKindText', { fg = colors.orange })
					set_hl(0, 'BlinkCmpKindTypeParameter', { fg = colors.yellow })
					set_hl(0, 'BlinkCmpKindUnit', { fg = colors.blue })
					set_hl(0, 'BlinkCmpKindValue', { fg = colors.orange })
					set_hl(0, 'BlinkCmpKindVariable', { fg = colors.orange })
					set_hl(0, 'BlinkCmpKindCopilot', { fg = colors.gray })

					set_hl(0, 'IlluminatedWordText', { bg = colors.bg2 })
					set_hl(0, 'IlluminatedWordRead', { bg = colors.bg2 })
					set_hl(0, 'IlluminatedWordWrite', { bg = colors.bg2 })
				end,
			})
			local palette = require('gruvbox').palette
			require('gruvbox').setup({
				italic = {
					strings = false,
					comments = global_config.plugins_config.gruvbox_comments_italic,
					folds = global_config.plugins_config.gruvbox_folds_italic,
				},
				overrides = {
					LspReferenceText = { underline = true },
					LspReferenceRead = { underline = true },
					LspReferenceWrite = { underline = true },

					-- noice.nvim
					NoiceCmdlinePopupBorder = { link = 'Normal' },
					NoiceCmdlinePopupTitle = { link = 'Normal' },

					-- Lualine
					-- check https://github.com/nvim-lualine/lualine.nvim/issues/1312 for more information
					StatusLine = { reverse = false },
					StatusLineNC = { reverse = false },

					-- nvim-scrollbar
					-- lua/plugins/nvim-scrollbar.lua change_highlight()

					-- vim-illuminate
					-- IlluminatedWordText = { link = 'GruvboxBg2' },
					-- IlluminatedWordRead = { link = 'GruvboxBg2' },
					-- IlluminatedWordWrite = { link = 'GruvboxBg2' },

					-- gitsigns.nvim
					GitSignsCurrentLineBlame = { fg = palette.dark4 },

					-- blink.cmp
					BlinkCmpSource = { link = 'GruvboxGray' },
					BlinkCmpLabelMatch = { link = 'GruvboxBlueBold' },
					BlinkCmpLabelDeprecated = { link = 'GruvboxGray' },
					BlinkCmpLabelDetail = { link = 'GruvboxGray' },
					BlinkCmpLabelDescription = { link = 'GruvboxGray' },

					-- todo-comments
					-- TodoBgTEST = { link = 'TodoFgTEST' },
					-- TodoBgHACK = { link = 'TodoFgHACK' },
					-- TodoBgNOTE = { link = 'TodoFgNOTE' },
					-- TodoBgTODO = { link = 'TodoFgTODO' },
					-- TodoBgFIX = { link = 'TodoFgFIX' },
					-- TodoBgPERF = { link = 'TodoFgPERF' },
					-- TodoBgWARN = { link = 'TodoFgWARN' },
				},
			})
			opt.background = 'dark'
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

	-- MINI.STARTER
	{
		'echasnovski/mini.starter',
		dependencies = {
			'echasnovski/mini.icons',
		},
		config = function()
			vim.cmd([[autocmd User MiniStarterOpened setlocal nofoldenable fillchars=eob:\ ]])

			local starter = require('mini.starter')
			local v = vim.version()
			local prerelease = v.api_prerelease and '(Pre-release) v' or 'v'

			local version = function()
				return 'NVIM ' .. prerelease .. tostring(vim.version())
			end

			local header = function()
				return version() .. '\n\n' .. [[
Nvim is open source and freely distributable
https://neovim.io/#chat

This Configuration:
https://github.com/gczcn/dotfile/blob/main/nvim/.config/nvim/init.lua]]
			end

			local footer = function()
				return
				os.date()
			end

			local recent_files = function(n, index_h, index, current_dir, show_path, show_icon)
				n = n or 5
				if current_dir == nil then current_dir = false end

				if show_path == nil then show_path = true end
				if show_path == false then show_path = function() return '' end end
				if show_path == true then
					show_path = function(path) return string.format(' (%s)', vim.fn.fnamemodify(path, ':~:.')) end
				end

				if show_icon == nil then show_icon = true end
				if show_icon == nil then show_icon = function() return '' end end
				if show_icon == true then
					show_icon = function(file_name)
						local icon, _ = require('nvim-web-devicons').get_icon(file_name)
						if not icon then icon = global_config.plugins_config.ascii_mode and 'F' or '󰈔' end
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
					local i = index or ''
					local items = {}
					for _, f in ipairs(vim.list_slice(files, 1, n)) do
						local file_name = vim.fn.fnamemodify(f, ':t')
						local name = index_h .. (i ~= '' and (i ~= 10 and i .. ' ' or '0 ') or '') .. show_icon(file_name) .. file_name .. show_path(f)
						i = i == '' and '' or i + 1
						items[#items + 1] = { action = 'edit ' .. f, name = name, section = section }
					end

					return items
				end
			end

			local opts = {
				evaluate_single = true,
				items = {
					-- Recent files (Current directory)
					recent_files(5, '', 1, vim.fn.getcwd()),

					-- Recent files
					recent_files(5, '`', 1),

					-- Builtin actions
					{ name = 'n New buffer', action = ':ene', section = 'Builtin actions' },
					{ name = 'q Quit Neovim', action = ':q', section = 'Builtin actions' },
					{ name = 'o Options', action = ':e ' .. vim.fn.stdpath('config') .. '/init.lua', section = 'Builtin actions' },

					-- Plugins actions
					{ name = 's Sync Plugins', action = ':Lazy sync', section = 'Plugins actions' },
					{ name = 'p Plugins', action = ':Lazy', section = 'Plugins actions' },
					-- { name = 'Mason', action = ':Mason', section = 'Plugins actions' },

					-- MiniFiles
					{ name = 'e File Browser', action = ':lua require("mini.files").open()', section = 'MiniFiles' },
					{ name = 'w File Browser (Options)', action = ':lua require("mini.files").open("' .. vim.fn.stdpath('config') .. '")', section = 'MiniFiles' },

					-- FzfLua
					{ name = 'f Find files', action = ':FzfLua files', section = 'FzfLua' },
					{ name = 'l Live grep', action = ':FzfLua live_grep', section = 'FzfLua' },
					{ name = 'g Grep', action = ':FzfLua grep', section = 'FzfLua' },
					{ name = 'h Help tags', action = ':FzfLua helptags', section = 'FzfLua' },
					{ name = 'r Recent files', action = ':FzfLua oldfiles', section = 'FzfLua' },
					-- { name = 'Bookmarks', action = ':Telescope bookmarks list', section = 'Telescope' },
					-- { name = 'o Options', action = string.format(':FzfLua files cwd=%s', vim.fn.stdpath('config')), section = 'FzfLua' },
				},
				-- items = nil,
				content_hooks = {
					starter.gen_hook.padding(7, 3),
					starter.gen_hook.adding_bullet(global_config.plugins_config.ascii_mode and '| ' or '▏ '),
					-- starter.gen_hook.adding_bullet('░ '),
				},
				header = header(),
				footer = footer(),
				-- footer = '',
				query_updaters = 'abcdefghijklmnopqrstuvwxyz0123456789_-.`',
				silent = true,

			}

			starter.setup(opts)

			create_user_command('MiniStarterToggle', function()
				if vim.o.filetype == 'ministarter' then
					require('mini.starter').close()
				else
					require('mini.starter').open()
				end
			end, {})

			keymap.set('n', '<leader>ts', '<cmd>MiniStarterToggle<CR>')

			create_autocmd('User', {
				pattern = 'LazyVimStarted',
				callback = function(ev)
					local stats = require('lazy').stats()
					local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
					starter.config.footer = 'loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms\n' .. footer()
					if vim.bo[ev.buf].filetype == 'ministarter' then
						pcall(starter.refresh)
					end
				end
			})
		end
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
					go_in       = 'I',
					go_in_plus  = 'i',
					go_out      = 'N',
					go_out_plus = 'n',
					mark_goto   = "'",
					mark_set    = 'm',
					reset       = '<BS>',
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

	-- MINI.AI
	{
		'echasnovski/mini.ai',
		event = 'VeryLazy',
		enabled = false,
		config = function()
			require('mini.ai').setup({
				mappings = {
					-- Main textobject prefixes
					around = 'a',
					inside = 'k',

					-- Next/last variants
					around_next = 'an',
					inside_next = 'kn',
					around_last = 'al',
					inside_last = 'kl',

					-- Move to corresponding edge of `a` textobject
					goto_left = 'g[',
					goto_right = 'g]',
				},
				n_lines = 500,
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

	-- MINI.PAIRS
	-- https://gist.github.com/tmerse/dc21ec932860013e56882f23ee9ad8d2
	{
		'echasnovski/mini.pairs',
		enabled = true,
		event = { 'VeryLazy' },
		version = '*',
		opts = {
			-- In which modes mappings from this `config` should be created
			modes = { insert = true, command = false, terminal = false },

			-- Global mappings. Each right hand side should be a pair information, a
			-- table with at least these fields (see more in |MiniPairs.map|):
			-- - <action> - one of 'open', 'close', 'closeopen'.
			-- - <pair> - two character string for pair to be used.
			-- By default pair is not inserted after `\`, quotes are not recognized by
			-- `<CR>`, `'` does not insert pair after a letter.
			-- Only parts of tables can be tweaked (others will use these defaults).
			mappings = {
				[')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
				[']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
				['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
				['['] = {
					action = 'open',
					pair = '[]',
					neigh_pattern = '.[%s%z%)}%]]',
					register = { cr = false },
					-- foo|bar -> press '[' -> foo[bar
					-- foobar| -> press '[' -> foobar[]
					-- |foobar -> press '[' -> [foobar
					-- | foobar -> press '[' -> [] foobar
					-- foobar | -> press '[' -> foobar []
					-- {|} -> press '[' -> {[]}
					-- (|) -> press '[' -> ([])
					-- [|] -> press '[' -> [[]]
				},
				['{'] = {
					action = 'open',
					pair = '{}',
					-- neigh_pattern = '.[%s%z%)}]',
					neigh_pattern = '.[%s%z%)}%]]',
					register = { cr = false },
					-- foo|bar -> press '{' -> foo{bar
					-- foobar| -> press '{' -> foobar{}
					-- |foobar -> press '{' -> {foobar
					-- | foobar -> press '{' -> {} foobar
					-- foobar | -> press '{' -> foobar {}
					-- (|) -> press '{' -> ({})
					-- {|} -> press '{' -> {{}}
				},
				['('] = {
					action = 'open',
					pair = '()',
					-- neigh_pattern = '.[%s%z]',
					neigh_pattern = '.[%s%z%)]',
					register = { cr = false },
					-- foo|bar -> press '(' -> foo(bar
					-- foobar| -> press '(' -> foobar()
					-- |foobar -> press '(' -> (foobar
					-- | foobar -> press '(' -> () foobar
					-- foobar | -> press '(' -> foobar ()
				},
				-- Single quote: Prevent pairing if either side is a letter
				['"'] = {
					action = 'closeopen',
					pair = '""',
					neigh_pattern = '[^%w\\][^%w]',
					register = { cr = false },
				},
				-- Single quote: Prevent pairing if either side is a letter
				["'"] = {
					action = 'closeopen',
					pair = "''",
					neigh_pattern = '[^%w\\][^%w]',
					register = { cr = false },
				},
				-- Backtick: Prevent pairing if either side is a letter
				['`'] = {
					action = 'closeopen',
					pair = '``',
					neigh_pattern = '[^%w\\][^%w]',
					register = { cr = false },
				},
			},
		},
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
			'nvim-treesitter/nvim-treesitter-context',
		},
		cmd = 'FzfLua',
		keys = {
			{ '<leader>ff', '<cmd>FzfLua files<CR>' },
			{ '<leader>fr', '<cmd>FzfLua oldfiles<CR>' },
			{ '<leader>fs', '<cmd>FzfLua live_grep<CR>' },
			{ '<leader>fc', '<cmd>FzfLua grep<CR>' },
			{ '<leader>fk', '<cmd>FzfLua keymaps<CR>' },
			{ '<leader>fh', '<cmd>FzfLua helptags<CR>' },
			-- { '<leader>fo', string.format('<cmd>FzfLua files cwd=%s<CR>', vim.fn.stdpath('config')) },
			{ '<leader>fb', '<cmd>FzfLua buffers<CR>' },
			{ '<leader>fw', '<cmd>FzfLua colorschemes<CR>' },
			{ '<leader>fm', '<cmd>FzfLua manpages<CR>' },
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
				{ '<leader>fo', string.format('<cmd>Telescope emoji theme=%s<CR>', theme) },
				{ '<leader>fg', string.format('<cmd>Telescope glyph theme=%s<CR>', theme) },
				{ '<leader>fe', string.format('<cmd>Telescope file_browser theme=%s<CR>', theme) },
				{ '<leader>fu', string.format('<cmd>Telescope undo theme=%s<CR>', theme) },
				{ '<leader>fp', string.format('<cmd>Telescope neoclip theme=%s<CR>', theme) },
				{ '<leader>fG', string.format('<cmd>Telescope nerdy theme=%s<CR>', theme) },
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
			'xiyaowong/telescope-emoji.nvim',
			'ghassan0/telescope-glyph.nvim',
			{ '2kabhishek/nerdy.nvim', cmd = 'Nerdy' },
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
			load_extension('emoji')
			load_extension('glyph')
			load_extension('nerdy')
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

			create_autocmd({ 'InsertLeave' }, {
				pattern = '*',
				callback = function()
					require('illuminate').resume()
				end,
			})

			create_autocmd({ 'InsertEnter' }, {
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
		opts = {},
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

	-- COKELINE, TABBAR, TABLINE
	{
		'willothy/nvim-cokeline',
		enabled = true,
		event = { 'User FileOpened', 'BufAdd' },
		dependencies = {
			'nvim-lua/plenary.nvim',
			'echasnovski/mini.icons',
			'stevearc/resession.nvim',
		},
		config = function()
			local is_picking_focus = require('cokeline.mappings').is_picking_focus
			local is_picking_close = require('cokeline.mappings').is_picking_close

			local get_tab_name = function(tabpage_handle)
				local name = vim.fn.split(api.nvim_buf_get_name(api.nvim_win_get_buf(api.nvim_tabpage_get_win(tabpage_handle))), '/')
				return name[#name]
			end

			local config = {
				special_file_type_symbol = '$ ',
				special_file_type = {
					['TelescopePrompt'] = 'Telescope',
					['fzf'] = 'FZF',
					['lazy'] = 'Lazy',
					['minifiles'] = 'Files',
					['mason'] = 'Mason',
				},
			}

			local colors = {
				default = 'gruvbox',
				colorschemes = {
					gruvbox = {
						dark = {
							focused = {
								normal = { bg = '#a89984', fg = '#282828', bold = true },
								insert = { bg = '#83a598', fg = '#282828', bold = true },
								command = { bg = '#b8bb26', fg = '#282828', bold = true },
								visual = { bg = '#fe8019', fg = '#282828', bold = true },
								select = { bg = '#fe8019', fg = '#282828', bold = true },
								replace = { bg = '#fb4934', fg = '#282828', bold = true },
								term = { bg = '#a89984', fg = '#282828', bold = true },
								normal_num = { bg = '#867869', fg = '#282828', bold = true },
								insert_num = { bg = '#458588', fg = '#282828', bold = true },
								command_num = { bg = '#98971a', fg = '#282828', bold = true },
								visual_num = { bg = '#d65d0e', fg = '#282828', bold = true },
								select_num = { bg = '#d65d0e', fg = '#282828', bold = true },
								replace_num = { bg = '#cc241d', fg = '#282828', bold = true },
								term_num = { bg = '#928374', fg = '#282828', bold = true },
								unique_prefix_fg = '#504945',
								diagnostic_error = { bg = '#fb4934', fg = '#282828', bold = true },
								diagnostic_warn = { bg = '#fabd2f', fg = '#282828', bold = true },
								diagnostic_info = { bg = '#83a598', fg = '#282828', bold = true },
								diagnostic_hint = { bg = '#8ec07c', fg = '#282828', bold = true },
							},
							not_focused = {
								normal = { bg = '#504945', fg = '#ebdbb2' },
								insert = { bg = '#504945', fg = '#ebdbb2' },
								command = { bg = '#504945', fg = '#ebdbb2' },
								visual = { bg = '#504945', fg = '#ebdbb2' },
								select = { bg = '#504945', fg = '#ebdbb2' },
								replace = { bg = '#504945', fg = '#ebdbb2' },
								term = { bg = '#504945', fg = '#ebdbb2' },
								normal_num = { bg = '#665c54', fg = '#ebdbb2' },
								insert_num = { bg = '#665c54', fg = '#ebdbb2' },
								command_num = { bg = '#665c54', fg = '#ebdbb2' },
								visual_num = { bg = '#665c54', fg = '#ebdbb2' },
								select_num = { bg = '#665c54', fg = '#ebdbb2' },
								replace_num = { bg = '#665c54', fg = '#ebdbb2' },
								term_num = { bg = '#665c54', fg = '#ebdbb2' },
								unique_prefix_fg = '#bdae93',
								diagnostic_error = { bg = '#504945', fg = '#fb4934' },
								diagnostic_warn = { bg = '#504945', fg = '#fabd2f' },
								diagnostic_info = { bg = '#504945', fg = '#83a598' },
								diagnostic_hint = { bg = '#504945', fg = '#8ec07c' },
							},
							tablinefill = {
								normal = { bg = '#3c3836', fg = '#a89984' },
								insert = { bg = '#504945', fg = '#ebdbb2' },
								command = { bg = '#7c6f64', fg = '#282828' },
								visual = { bg = '#7c6f64', fg = '#282828' },
								select = { bg = '#7c6f64', fg = '#282828' },
								replace = { bg = '#282828', fg = '#ebdbb2' },
								term = { bg = '#3c3836', fg = '#a89984' },
							},
							quit = { bg = '#fb4934', fg = '#282828', bold = true }
						},
						light = {
							focused = {
								normal = { bg = '#7c6f64', fg = '#f9f5d7', bold = true },
								insert = { bg = '#076678', fg = '#f9f5d7', bold = true },
								command = { bg = '#79740e', fg = '#f9f5d7', bold = true },
								visual = { bg = '#af3a03', fg = '#f9f5d7', bold = true },
								select = { bg = '#af3a03', fg = '#f9f5d7', bold = true },
								replace = { bg = '#9d0006', fg = '#f9f5d7', bold = true },
								term = { bg = '#7c6f64', fg = '#f9f5d7', bold = true },
								normal_num = { bg = '#928374', fg = '#f9f5d7', bold = true },
								insert_num = { bg = '#458588', fg = '#f9f5d7', bold = true },
								command_num = { bg = '#98971a', fg = '#f9f5d7', bold = true },
								visual_num = { bg = '#d65d0e', fg = '#f9f5d7', bold = true },
								select_num = { bg = '#d65d0e', fg = '#f9f5d7', bold = true },
								replace_num = { bg = '#cc241d', fg = '#f9f5d7', bold = true },
								term_num = { bg = '#928374', fg = '#f9f5d7', bold = true },
								unique_prefix_fg = '#d5c4a1',
								diagnostic_error = { bg = '#9d0006', fg = '#f9f5d7', bold = true },
								diagnostic_warn = { bg = '#b57614', fg = '#f9f5d7', bold = true },
								diagnostic_info = { bg = '#076678', fg = '#f9f5d7', bold = true },
								diagnostic_hint = { bg = '#427b58', fg = '#f9f5d7', bold = true },
							},
							not_focused = {
								normal = { bg = '#d5c4a1', fg = '#7c6f64' },
								insert = { bg = '#d5c4a1', fg = '#7c6f64' },
								command = { bg = '#d5c4a1', fg = '#7c6f64' },
								visual = { bg = '#d5c4a1', fg = '#7c6f64' },
								select = { bg = '#d5c4a1', fg = '#7c6f64' },
								replace = { bg = '#d5c4a1', fg = '#7c6f64' },
								term = { bg = '#d5c4a1', fg = '#7c6f64' },
								normal_num = { bg = '#bdae93', fg = '#7c6f64' },
								insert_num = { bg = '#bdae93', fg = '#7c6f64' },
								command_num = { bg = '#bdae93', fg = '#7c6f64' },
								visual_num = { bg = '#bdae93', fg = '#7c6f64' },
								select_num = { bg = '#bdae93', fg = '#7c6f64' },
								replace_num = { bg = '#bdae93', fg = '#7c6f64' },
								term_num = { bg = '#bdae93', fg = '#7c6f64' },
								unique_prefix_fg = '#bdae93',
								diagnostic_error = { bg = '#d5c4a1', fg = '#9d0006' },
								diagnostic_warn = { bg = '#d5c4a1', fg = '#b57614' },
								diagnostic_info = { bg = '#d5c4a1', fg = '#076678' },
								diagnostic_hint = { bg = '#d5c4a1', fg = '#427b58' },
							},
							tablinefill = {
								normal = { bg = '#ebdbb2', fg = '#7c6f64' },
								insert = { bg = '#d5c4a1', fg = '#3c3835' },
								command = { bg = '#ebdbb2', fg = '#7c6f64' },
								visual = { bg = '#7c6f64', fg = '#f9f5d7' },
								select = { bg = '#7c6f64', fg = '#f9f5d7' },
								replace = { bg = '#d5c4a1', fg = '#3c3836' },
								term = { bg = '#ebdbb2', fg = '#7c6f64' },
							},
							quit = { bg = '#9d0006', fg = '#f9f5d7', bold = true }
						},
					},
				},
			}

			local get_mode = function()
				local mode = api.nvim_get_mode().mode or 'n'
				local mode_first_char = string.sub(mode, 1, 1)
				if mode_first_char == 'n' then return 'normal'
				elseif string.lower(mode_first_char) == 'v' or mode == '\22' or mode == '\22s' then return 'visual'
				elseif string.lower(mode_first_char) == 's' or mode == '\19' then return 'select'
				elseif mode_first_char == 'i' then return 'insert'
				elseif mode_first_char == 'R' then return 'replace'
				elseif mode_first_char == 'c' then return 'command'
				elseif mode_first_char == 't' then return 'term'
				else return 'normal'
				end
			end

			local get_colors = function()
				return colors['colorschemes'][
					colors['colorschemes'][vim.g.colors_name]
					and vim.g.colors_name
					or colors.default
					][(vim.o.background == 'dark' or vim.o.background == 'light') and vim.o.background or 'dark']
			end

			local get_focus_colors = function(is_focused)
				return get_colors()[is_focused and 'focused' or 'not_focused']
			end

			create_autocmd({ 'ModeChanged', 'ColorScheme', 'LspAttach' }, {
				pattern = '*',
				callback = function()
					api.nvim_set_hl(0, 'TabLineFill', get_colors()['tablinefill'][get_mode()])
				end
			})
			api.nvim_set_hl(0, 'TabLineFill', get_colors()['tablinefill'][get_mode()])

			-- Set keymaps
			local opts = { noremap = true, silent = true }

			-- Buffers
			-- keymap.set('n', ']0', '<cmd>LualineBuffersJump $<CR>', opts)
			for i = 1, 9 do
				keymap.set('n', (']%s'):format(global_config.middle_row_of_keyboard[i + 1]), ('<Plug>(cokeline-focus-%s)'):format(i), opts)
			end
			keymap.set('n', ']f', function()
				vim.ui.input({ prompt = 'Buffer Index:' }, function(index)
					if index then
						vim.cmd(('call feedkeys("\\<Plug>\\(cokeline-focus-%s)")'):format(index))
					end
				end)
			end)

			-- Tabs
			keymap.set('n', '<TAB>', '<cmd>tabnext<CR>', opts)
			keymap.set('n', '<S-TAB>', '<cmd>tabprev<CR>', opts)

			require('cokeline').setup({
				default_hl = {
					fg = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode()]['fg'] end,
					bg = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode()]['bg'] end,
					bold = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode()]['bold'] end,
					italic = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode()]['italic'] end,
					underline = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode()]['underline'] end,
					undercurl = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode()]['undercurl'] end,
					strikethrough = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode()]['strikethrough'] end,
				},
				components = {
					{
						text = function(buffer) return ' ' .. buffer.index .. ' ' end,
						bg = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode() .. '_num']['bg'] end,
						fg = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode() .. '_num']['fg'] end,
						bold = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode() .. '_num']['bold'] end,
						italic = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode() .. '_num']['italic'] end,
						underline = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode() .. '_num']['underline'] end,
						undercurl = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode() .. '_num']['undercurl'] end,
						strikethrough = function(buffer) return get_focus_colors(buffer.is_focused)[get_mode() .. '_num']['strikethrough'] end,
					},
					{
						text = function(buffer)
							return ' ' .. ((is_picking_focus() or is_picking_close()) and buffer.pick_letter or buffer.devicon.icon)
						end,
						style = function(_)
							return (is_picking_focus() or is_picking_close()) and 'italic,bold' or nil
						end,
						fg = function(buffer)
							return buffer.is_focused and get_focus_colors(buffer.is_focused)[get_mode()]['fg'] or buffer.devicon.color
						end,
					},
					{
						text = function(buffer)
							return buffer.unique_prefix
						end,
						fg = function(buffer)
							return get_colors()[buffer.is_focused and 'focused' or 'not_focused']['unique_prefix_fg']
						end,
					},
					{
						text = function(buffer)
							return buffer.filename .. ' '
						end,
					},
					{
						text = function(buffer)
							return buffer.is_modified and (global_config.plugins_config.nerd_font_circle_and_square and ' ' or '● ') or ''
						end,
					},
					{
						text = function(buffer)
							return buffer.diagnostics.errors ~= 0 and ((buffer.is_focused and ' ' or '') .. buffer.diagnostics.errors .. ' ') or ''
						end,
						bg = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_error']['bg'] end,
						fg = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_error']['fg'] end,
						bold = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_error']['bold'] end,
						italic = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_error']['italic'] end,
						underline = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_error']['underline'] end,
						undercurl = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_error']['undercurl'] end,
						strikethrough = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_error']['strikethrough'] end,
					},
					{
						text = function(buffer)
							return buffer.diagnostics.warnings ~= 0 and ((buffer.is_focused and ' ' or '') .. buffer.diagnostics.warnings .. ' ') or ''
						end,
						bg = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_warn']['bg'] end,
						fg = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_warn']['fg'] end,
						bold = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_warn']['bold'] end,
						italic = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_warn']['italic'] end,
						underline = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_warn']['underline'] end,
						undercurl = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_warn']['undercurl'] end,
						strikethrough = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_warn']['strikethrough'] end,
					},
					{
						text = function(buffer)
							return buffer.diagnostics.hints ~= 0 and ((buffer.is_focused and ' ' or '') .. buffer.diagnostics.hints .. ' ') or ''
						end,
						bg = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_hint']['bg'] end,
						fg = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_hint']['fg'] end,
						bold = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_hint']['bold'] end,
						italic = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_hint']['italic'] end,
						underline = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_hint']['underline'] end,
						undercurl = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_hint']['undercurl'] end,
						strikethrough = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_hint']['strikethrough'] end,
					},
					{
						text = function(buffer)
							return buffer.diagnostics.infos ~= 0 and ((buffer.is_focused and ' ' or '') .. buffer.diagnostics.infos .. ' ') or ''
						end,
						bg = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_info']['bg'] end,
						fg = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_info']['fg'] end,
						bold = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_info']['bold'] end,
						italic = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_info']['italic'] end,
						underline = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_info']['underline'] end,
						undercurl = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_info']['undercurl'] end,
						strikethrough = function(buffer) return get_focus_colors(buffer.is_focused)['diagnostic_info']['strikethrough'] end,
					},
					{
						text = function(buffer)
							local text = buffer.is_last and config.special_file_type[vim.o.filetype]
							return text and ' ' .. config.special_file_type_symbol .. text or ''
						end,
						bg = function() return get_colors()['tablinefill'][get_mode()]['bg'] end,
						fg = function() return get_colors()['tablinefill'][get_mode()]['fg'] end,
						bold = function() return get_colors()['tablinefill'][get_mode()]['bold'] end,
						italic = function() return get_colors()['tablinefill'][get_mode()]['italic'] end,
						underline = function() return get_colors()['tablinefill'][get_mode()]['underline'] end,
						undercurl = function() return get_colors()['tablinefill'][get_mode()]['undercurl'] end,
						strikethrough = function() return get_colors()['tablinefill'][get_mode()]['strikethrough'] end,
					},
				},
				tabs = {
					placement = 'right',
					components = {
						{
							text = function(tabpage)
								local icon = Utils.get_file_icon(get_tab_name(tabpage.number), api.nvim_win_call(api.nvim_tabpage_get_win(tabpage.number), function() return vim.o.filetype end))
								return icon and ' ' .. icon .. ' ' or ''
							end,
							fg = function(tabpage)
								if tabpage.is_active then
									return get_focus_colors(tabpage.is_active)[get_mode()]['fg']
								else
									local _, color = Utils.get_file_icon(get_tab_name(tabpage.number), api.nvim_win_call(api.nvim_tabpage_get_win(tabpage.number), function() return vim.o.filetype end))
									return color
								end
							end,
							bg = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode()]['bg'] end,
							bold = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode()]['bold'] end,
							italic = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode()]['italic'] end,
							underline = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode()]['underline'] end,
							strikethrough = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode()]['strikethrough'] end,
						},
						{
							text = function(tabpage)
								local name = get_tab_name(tabpage.number)
								return name and name .. ' ' or ''
							end,
							bg = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode()]['bg'] end,
							fg = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode()]['fg'] end,
							bold = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode()]['bold'] end,
							italic = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode()]['italic'] end,
							underline = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode()]['underline'] end,
							strikethrough = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode()]['strikethrough'] end,
						},
						{
							text = function(tabpage)
								return ' ' .. tabpage.number .. ' '
							end,
							bg = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode() .. '_num']['bg'] end,
							fg = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode() .. '_num']['fg'] end,
							bold = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode() .. '_num']['bold'] end,
							italic = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode() .. '_num']['italic'] end,
							underline = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode() .. '_num']['underline'] end,
							strikethrough = function(tabpage) return get_focus_colors(tabpage.is_active)[get_mode() .. '_num']['strikethrough'] end,
						},
						{
							text = function(tabpage)
								return tabpage.is_last and ' X ' or ''
							end,
							bg = function() return get_colors()['quit']['bg'] end,
							fg = function() return get_colors()['quit']['fg'] end,
							bold = function() return get_colors()['quit']['bold'] end,
							italic = function() return get_colors()['quit']['italic'] end,
							underline = function() return get_colors()['quit']['underline'] end,
							undercurl = function() return get_colors()['quit']['undercurl'] end,
							strikethrough = function() return get_colors()['quit']['strikethrough'] end,
							on_click = function()
								vim.ui.input({ prompt = 'Quit Neovim? Y/n: ' }, function(input)
									if input and (input == '' or string.lower(input) == 'y') then
										vim.cmd.qa()
									end
								end)
							end
						}
					},
				},
			})
		end,
	},

	-- LUALINE, STATUSLINE
	{
		'nvim-lualine/lualine.nvim',
		event = { 'User FileOpened', 'BufAdd' },
		dependencies = {
			'echasnovski/mini.icons',
			'meuter/lualine-so-fancy.nvim',
		},
		config = function()

			require('lualine').setup({
				options = {
					component_separators = '',
					section_separators = { left = '', right = '' },
					disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'ministarter' } },
					globalstatus = true,
				},
				sections = {
					lualine_a = { 'mode' },
					lualine_b = { 'filename', 'searchcount', 'selectioncount' },
					lualine_c = {
						'branch',
						'diff',
						'filesize',
						'filetype',
						'encoding',
						{
							'diagnostics',
							symbols = {
								error = 'E',
								warn = 'W',
								hint = 'H',
								info = 'I',
							},
						},
					},

					lualine_x = {
						-- { 'filename', path = 3 },
						-- stylua: ignore
						{
							function() return require('noice').api.status.command.get() end,
							cond = function() return package.loaded['noice'] and require('noice').api.status.command.has() end,
							color = function()
								return { fg = Utils.get_hl('Statement') }
							end
						},

						-- stylua: ignore
						{
							function() return require('noice').api.status.mode.get() end,
							cond = function() return package.loaded['noice'] and require('noice').api.status.mode.has() end,
							color = function()
								return { fg = Utils.get_hl('Constant') }
							end
						},
						'fancy_lsp_servers',
						'tabnine',
						'hostname',
						'fileformat',
					},
					lualine_y = {
						{ 'progress', separator = ' ', padding = { left = 1, right = 0 } },
						{ 'location', padding = { left = 0, right = 1 } },
					},
					lualine_z = { 'os.date("%D %R")' },
				},
			})
		end,
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
			'nvim-treesitter/nvim-treesitter-context',
			'HiPhish/rainbow-delimiters.nvim',
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
			-- 	group = api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
			-- 	callback = function()
			-- 		if require("nvim-treesitter.parsers").has_parser() then
			-- 			opt.foldmethod = "expr"
			-- 			opt.foldexpr = "nvim_treesitter#foldexpr()"
			-- 		else
			-- 			opt.foldmethod = "syntax"
			-- 		end
			-- 	end,
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
		enabled = true,
		event = 'VeryLazy',
		opts = {
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
		cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
		ft = { 'markdown' },
		build = function()
			require('lazy').load({ plugins = { 'markdown-preview.nvim' } })
			vim.fn['mkdp#util#install']()
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
					markdown = function ()
						vim.cmd [[MarkdownPreviewToggle]]
					end,
					java = {
						'cd $dir &&',
						'javac $fileName &&',
						'java $fileNameWithoutExt'
					},
					python = function() return 'python3 $file ' .. vim.g.code_runner_run_args end,
					go = function()  end,
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
		enabled = true,
		config = function()
			require('ibl').setup({
				indent = {
					char = global_config.plugins_config.ascii_mode and '|' or '▏',
					tab_char = global_config.plugins_config.ascii_mode and '|' or '▏',
				},
			})
		end,
	},

	-- SUDA, SUDO
	{
		'lambdalisue/vim-suda',
		enabled = vim.fn.has('win32') and false or true,
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

	-- NOICE
	{
		'folke/noice.nvim',
		enabled = true,
		dependencies = {
			'MunifTanjim/nui.nvim',
		},
		keys = {
			-- { '<leader>fn', '<cmd>NoiceFzf<CR>' },
			-- { '<leader>h', '<cmd>NoiceDismiss<CR>' },
			{ '<S-Enter>', function() require('noice').redirect(vim.fn.getcmdline()) end, mode = 'c', desc = 'Redirect Cmdline' },
			{ '<leader>anl', function() require('noice').cmd('last') end, desc = 'Noice Last Message' },
			{ '<leader>anh', function() require('noice').cmd('history') end, desc = 'Noice History' },
			{ '<leader>ana', function() require('noice').cmd('all') end, desc = 'Noice All' },
			-- { '<leader>and', function() require('noice').cmd('dismiss') end, desc = 'Dismiss All' },
			{ '<c-f>', function() if not require('noice.lsp').scroll(4) then return '<c-f>' end end, silent = true, expr = true, desc = 'Scroll Forward', mode = {'i', 'n', 's'} },
			{ '<c-b>', function() if not require('noice.lsp').scroll(-4) then return '<c-b>' end end, silent = true, expr = true, desc = 'Scroll Backward', mode = {'i', 'n', 's'}},
		},
		event = 'VeryLazy',
		opts = {
			cmdline = {
				-- enabled = false,
				format = {
					cmdline = { pattern = '^:', icon = ('%s>'):format(global_config.plugins_config.noice_classic_cmdline and ' ' or ''), lang = 'vim' },
					search_down = { kind = 'search', pattern = '^/', icon = ' Up', lang = 'regex' },
					search_up = { kind = 'search', pattern = '^%?', icon = ' Down', lang = 'regex' },
					filter = { pattern = '^:%s*!', icon = ('%s$'):format(global_config.plugins_config.noice_classic_cmdline and ' ' or ''), lang = 'bash' },
					lua = { pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' }, icon = (global_config.plugins_config.ascii_mode and '%sL' or '%s'):format(global_config.plugins_config.noice_classic_cmdline and ' ' or ''), lang = 'lua' },
					help = { pattern = '^:%s*he?l?p?%s+', icon = ('%s?'):format(global_config.plugins_config.noice_classic_cmdline and ' ' or '') },
					input = { view = global_config.plugins_config.noice_classic_cmdline and 'cmdline' or nil, icon = ' 󰥻 ' },
				},
				view = global_config.plugins_config.noice_classic_cmdline and 'cmdline' or 'cmdline_popup',
			},
			messages = {
				view_history = 'popup',
				-- view_search = false,
			},
			views = {
				cmdline_popup = { border = { style = global_config.plugins_config.border, } },
				cmdline_input = { border = { style = global_config.plugins_config.border, } },
				confirm = { border = { style = global_config.plugins_config.border, } },
				popup = { border = { style = global_config.plugins_config.border } },
				popup_menu = { border = { style = global_config.plugins_config.border, } },
				mini = { timeout = 3000 },
				-- hover = { border = { style = 'single', padding = { 0, 2 } } },
			},
			presets = {
				inc_rename = true,
				bottom_search = true,
				-- command_palette = true,
				long_message_to_split = true,
			},
			format = {
				---@class NoiceFormatOptions.level
				level = {
					icons = { error = 'E:', warn = 'W:', info = 'I:' },
				},
			},
		},
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
	-- 	'luukvbaal/statuscol.nvim',
	-- 	config = function ()
	-- 		local builtin = require("statuscol.builtin")
	-- 		require("statuscol").setup({
	-- 			relculright = true,
	-- 			segments = {
	-- 				-- { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
	-- 				{
	-- 					sign = { namespace = { "diagnostic/signs" }, maxwidth = 2, auto = true },
	-- 					click = "v:lua.ScSa"
	-- 				},
	-- 				{ text = { builtin.lnumfunc }, click = "v:lua.ScLa", },
	-- 				{
	-- 					sign = { name = { ".*" }, maxwidth = 2, colwidth = 1, auto = true, wrap = true },
	-- 					click = "v:lua.ScSa"
	-- 				},
	-- 			}
	-- 		})
	-- 	end
	-- },

	-- SNACKS
	{
		'folke/snacks.nvim',
		lazy = false,
		priority = 1000,
		config = function()
			local Snacks = require('snacks')
			Snacks.setup({
				bigfile = {},
				notifier = {},
				quickfile = {},
				-- statuscolumn = {
				-- 	folds = {
				-- 		open = true,
				-- 		git_hl = true,
				-- 	},
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

			keymap.set('n', '<leader>ar', Snacks.rename.rename_file)
			keymap.set('n', '<leader>h', Snacks.notifier.hide)
			keymap.set('n', '<leader>fN', Snacks.notifier.show_history)
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

	-- CONFORM, FORMAT
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
		event = 'User FileOpened',
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

	-- LINT, LINTER
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

	-- LSP (Language Server Protocol)
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
			local opts = { noremap = true, silent = true }
			local on_attach = function(_, bufnr)
				opts.buffer = bufnr

				-- set keybinds
				opts.desc = 'Show LSP references'
				keymap.set('n', 'gR', '<cmd>FzfLua lsp_references<CR>', opts) -- show definition, references

				opts.desc = 'Go to declaration'
				keymap.set('n', 'gD', '<cmd>FzfLua lsp_declarations<CR>', opts) -- go to declaration

				opts.desc = 'Show LSP definitions'
				keymap.set('n', 'gd', '<cmd>FzfLua lsp_definitions<CR>', opts) -- show lsp definitions

				opts.desc = 'Show LSP implementations'
				keymap.set('n', 'gi', '<cmd>FzfLua lsp_implementations<CR>', opts) -- show lsp implementations

				opts.desc = 'Show LSP type definitions'
				keymap.set('n', 'gT', '<cmd>FzfLua lsp_typedefs<CR>', opts) -- show lsp type definitions

				opts.desc = 'See available code actions'
				keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = 'Smart rename'
				keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

				opts.desc = 'Show buffer diagnostics'
				keymap.set('n', '<leader>D', '<cmd>FzfLua lsp_document_diagnostics<CR>', opts) -- show  diagnostics for file

				opts.desc = 'Show line diagnostics'
				keymap.set('n', '<leader>dl', vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = 'Go to previous diagnostic'
				keymap.set('n', '<M-[>', function() vim.diagnostic.jump({ count = -1, float = true }) end, opts) -- jump to previous diagnostic in buffer

				opts.desc = 'Go to next diagnostic'
				keymap.set('n', '<M-]>', function() vim.diagnostic.jump({ count = 1, float = true }) end, opts) -- jump to next diagnostic in buffer

				opts.desc = 'Show documentation for what is under cursor'
				keymap.set('n', 'U', vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = 'Restart LSP'
				keymap.set('n', '<leader>rs', '<cmd>LspRestart<CR>', opts) -- mapping to restart lsp if necessary
			end

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
								tagSupport = if_nil(override.tagSupport, {
									valueSet = {
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
				on_attach = on_attach,
			})

			-- configure typescript server with plugin
			lspconfig['ts_ls'].setup({
				capabilities = capabilities(),
				on_attach = on_attach,
			})

			-- configure css server
			lspconfig['cssls'].setup({
				capabilities = capabilities(),
				on_attach = on_attach,
			})

			-- configure python server
			-- lspconfig['pyright'].setup({
			-- 	capabilities = capabilities(),
			-- 	on_attach = on_attach,
			-- })

			lspconfig['basedpyright'].setup({
				capabilities = capabilities(),
				on_attach = on_attach,
				settings = {
					basedpyright = {
						typeCheckingMode = 'standard',
					},
				},
			})

			-- configure lua server (with special settings)
			lspconfig['lua_ls'].setup({
				-- capabilities = capabilities(),
				on_attach = on_attach,
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
					},
				},
			})

			-- configure Go language server
			lspconfig['gopls'].setup({
				capabilities = capabilities(),
				on_attach = on_attach,
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
				on_attach = on_attach,
				cmd = { 'bash-language-server', 'start' },
			})

			lspconfig['fish_lsp'].setup({
				capabilities = capabilities(),
				on_attach = on_attach,
			})

			lspconfig['vimls'].setup({
				capabilities = capabilities(),
				on_attach = on_attach,
			})

			-- configure C and C++ ... language server
			lspconfig['clangd'].setup({
				capabilities = capabilities(),
				on_attach = on_attach,
				cmd = {
					'clangd',
					'--background-index',
				}
			})
			-- lspconfig['ccls'].setup({
			-- 	capabilities = capabilities(),
			-- 	on_attach = on_attach,
			-- 	filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'opencl' },
			-- 	root_dir = function(fname)
			-- 		return vim.loop.cwd() -- current working directory
			-- 	end,
			-- 	init_options = { cache = {
			-- 		-- directory = vim.env.XDG_CACHE_HOME .. '/ccls/',
			-- 		vim.fs.normalize '~/.cache/ccls' -- if on nvim 0.8 or higher
			-- 	} },
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
		build = 'rustup run nightly cargo build --release',
		-- build = 'cargo build --release',
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
								-- 	ellipsis = false,
								-- 	text = function(ctx)
								-- 		return ' ' .. ctx.kind_icon .. ' '
								-- 	end,
								-- 	highlight = function(ctx)
								-- 		---@diagnostic disable-next-line: ambiguity-1
								-- 		return require('blink.cmp.completion.windows.render.tailwind').get_hl(ctx)
								-- 			or 'BlinkCmpKind' .. ctx.kind
								-- 	end,
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

			-- if enabled_tabnine then
			-- 	opts.sources.providers.cmp_tabnine = {
			-- 		name = 'cmp_tabnine',
			-- 		module = 'blink.compat.source',
			-- 		score_offset = -3,
			-- 	}
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

	opt.cmdheight = 0
	opt.laststatus = 0
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
