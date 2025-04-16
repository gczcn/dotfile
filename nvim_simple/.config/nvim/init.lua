-- =============================================================================
-- My Neovim Configuration (Simplified Version)
-- https://github.com/gczcn/dotfile/
-- Author: Zixuan Chu <494353540@qq.com>
-- =============================================================================

-- =============================================================================
-- Global vars
-- Tags: VAR, VARS, GLOBAL
-- =============================================================================

local keymap = vim.keymap
local api = vim.api
local opt = vim.opt
local create_user_command = api.nvim_create_user_command
local create_autocmd = api.nvim_create_autocmd
local create_augroup = api.nvim_create_augroup

-- Options
local option_enabled_plugins = true
local option_remove_padding_around_neovim_instance = false
local option_nerdfont_circle_and_square = true
local option_ascii_mode = false
local option_enabled_copilot = false
local option_enabled_tabnine = false

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
	keymap.set('i', ',n', '---<CR><CR>', { buffer = true }) -- dashes
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
keymap.set('v', 'kr', '`[`]', keymaps_opts)
keymap.set({ 'n', 'v', 'o' }, '0', '`', keymaps_opts)

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
keymap.set('n', 'gX', function() Utils.goto_github(vim.fn.expand('<cfile>')) end)
keymap.set('n', '<leader><leader>', '<cmd>lua vim.diagnostic.config({virtual_lines=not vim.diagnostic.config().virtual_lines})<CR>')

-- =============================================================================
-- Options
-- Tags: OPT, OPTS, OPTION, OPTIONS
-- =============================================================================

vim.g.encoding = 'UTF-8'

opt.autowrite = true
opt.breakindent = true -- Wrap indent to match line start
opt.conceallevel = 2 -- Hide * markup for hold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.copyindent = true -- Copy the previous indentation on autoindenting
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
opt.maxmempattern = 5000
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
opt.statuscolumn = '%s%l %C%{%(&foldcolumn>0?" ":"")%}'
opt.tabstop = 8 -- Number of spaces tabs count for
opt.termguicolors = true -- Enable true colors
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
-- opt.virtualedit = 'block' -- Allow cursor to move where there is no text in visual block mode
opt.winblend = 10
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

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
brew upgrade gh

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
yes | sudo pacman -S github-cli

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
yes | sudo pacman -S github-cli

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
if option_remove_padding_around_neovim_instance then
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

create_autocmd('FileType', {
	pattern = { 'json', 'json5', 'jsonc', 'lsonc', 'markdown' },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
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
		Utils.setup_markdown()
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
-- Plugins
-- Tags: PLUG, PLUGIN, PLUGINS
-- =============================================================================

-- LAZYNVIM
local lazy_config = option_enabled_plugins and {
	install = { colorscheme = { 'gruvbox', 'habamax' } },
	checker = { enabled = true, notify = false, },
	change_detection = { notify = false },
	ui = {
		icons = option_nerdfont_circle_and_square and {
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

local plugins = option_enabled_plugins and {
	-- COLORSCHEMES
	--- GRUVBOX-MATERIAL
	{
		'sainnhe/gruvbox-material',
		priority = 1000,
		config = function()
			create_autocmd('ColorScheme', {
				group = create_augroup('custom_highlights_gruvbox_material', {}),
				pattern = 'gruvbox-material',
				callback = function()
					local config = vim.fn['gruvbox_material#get_configuration']()
					local palette = vim.fn['gruvbox_material#get_palette'](config.background, config.foreground, config.colors_override)
					local set_hl = vim.fn['gruvbox_material#highlight']

					set_hl('WinBar', palette.fg0, palette.bg2)

					-- Custom
					set_hl('DiagnosticNumHlError', palette.red, palette.none, 'bold')
					set_hl('DiagnosticNumHlWarn', palette.yellow, palette.none, 'bold')
					set_hl('DiagnosticNumHlHint', palette.green, palette.none, 'bold')
					set_hl('DiagnosticNumHlInfo', palette.blue, palette.none, 'bold')
				end,
			})

			opt.background = 'dark'
			vim.g.gruvbox_material_disable_italic_comment = 1
			vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
			vim.g.gruvbox_material_inlay_hints_background = 'dimmed'
			vim.g.gruvbox_material_better_performance = 1

			vim.cmd.colorscheme('gruvbox-material')
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

	-- MINI.ICONS
	{
		'echasnovski/mini.icons',
		lazy = true,
		opts = {
			style = option_ascii_mode and 'ascii' or 'glyph',
			file = {
				['.keep'] = { glyph = option_ascii_mode and 'G' or '󰊢', hl = 'MiniIconsGrey' },
				['devcontainer.json'] = { glyph = option_ascii_mode and 'D' or '', hl = 'MiniIconsAzure' },
			},
			filetype = {
				dotenv = { glyph = option_ascii_mode and 'D' or '', hl = 'MiniIconsYellow' },
				go = { glyph = option_ascii_mode and 'G' or '', hl = 'MiniIconsBlue' },
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
					row = 0.50,
					border = 'single',
					backdrop = 100,
					preview = {
						border = 'single'
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
			return {
				{ '<leader>fo', '<cmd>Telescope emoji<CR>' },
				{ '<leader>fg', '<cmd>Telescope glyph<CR>' },
				{ '<leader>fe', '<cmd>Telescope file_browser<CR>' },
				{ '<leader>fu', '<cmd>Telescope undo<CR>' },
				{ '<leader>fp', '<cmd>Telescope neoclip<CR>' },
				{ '<leader>fG', '<cmd>Telescope nerdy<CR>' },
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

			telescope.setup({
				defaults = {
					borderchars = {
						prompt = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
						results = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
						preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
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
		config = function()
			require('ibl').setup({
				indent = {
					char = option_ascii_mode and '|' or '▏',
					tab_char = option_ascii_mode and '|' or '▏',
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
						Snacks.util.wo(0, { foldmethod = 'manual', statuscolumn = '', conceallevel = 0 })
						vim.b.minianimate_disable = true
						vim.schedule(function()
							if vim.api.nvim_buf_is_valid(ctx.buf) then
								vim.bo[ctx.buf].syntax = ctx.ft
							end
						end)
					end,
				},
				quickfile = {},

			})
		end,
	},

	-- COPILOT
	{
		'zbirenbaum/copilot.lua',
		cmd = 'Copilot',
		event = 'InsertEnter',
		enabled = option_enabled_copilot,
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
		enabled = option_enabled_tabnine,
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

} or {}

-- =============== Lazy.nvim setup ===============
if option_enabled_plugins then
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
