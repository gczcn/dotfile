-- =============================================================================
-- My Neovim Config (Single File Version)
-- wuthor: gczcn
--
-- Dependencies:
--   Neovim - (latest or nightly version)
--   ripgrep - for fzf.lua
--   fd - for fzf.lua
--   node
--   npm
--   fzf - for fzf.lua
--   gcc
--   rust - nightly version for blink.cmp
--
--   Language Servers:
--     clangd
--     typescript-language-server
--     pyright
--     lua-language-server
--     gopls
--     tailwindcss-language-server
--     bash-language-server
--     vscode-langservers-extracted
--     graphql-language-service-cli
--     svelte-language-server
--     emmet-ls
--     prisma-language-server
--     vim-language-server
--
--   Formatters:
--     black
--     stylua
--     shfmt
--
-- Run `:RunShellScript [install/update]_dependencies_[package_manager]` to
-- install or update dependencies.
-- package_manager: [homebrew/pacman]
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

-- Middle Row of Keyboard      |  0    1    2    3    4    5    6    7    8    9  |
local middle_row_of_keyboard = { 'o', 'a', 'r', 's', 't', 'd', 'h', 'n', 'e', 'i' } -- Colemak
-- local middle_row_of_keyboard = { ';', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l' } -- Qwerty

local enabled_plugins = true
local enabled_copilot = false
local enabled_tabnine = false

local plugins_config = {
  border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
}

-- =============================================================================
-- Functions
-- Tags: FUN, FUNC, FUNCTION, FUNCTIONS
-- =============================================================================

local simple_mode = function()
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
    ['s'] = 'SEL',
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
  return mode_map[api.nvim_get_mode().mode] or '__'
end

-- Copy from https://github.com/LazyVim/LazyVim/blob/f11890bf99477898f9c003502397786026ba4287/lua/lazyvim/util/ui.lua#L171-L187
local get_hl = function(name, bg)
  ---@type {foreground?:number}?
  ---@diagnostic disable-next-line: deprecated
  local hl = api.nvim_get_hl and api.nvim_get_hl(0, { name = name, link = false }) or api.nvim_get_hl_by_name(name, true)
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

local autocmd_attach_file_browser = function(plugin_name, plugin_open)
  local previous_buffer_name
  api.nvim_create_autocmd('BufEnter', {
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
-- Shell scripts
-- Tags: SH, SHELL, SCRIPT, SCRIPTS
-- =============================================================================

local shell_scripts = {}

shell_scripts.install_dependencies_homebrew = [[
  brew update

  brew install ripgrep
  brew install fd
  brew install node
  brew install npm
  brew install fzf

  brew install gcc

  brew install llvm
  brew install typescript-language-server
  brew install pyright
  brew install lua-language-server
  brew install gopls
  brew install tailwindcss-language-server
  brew install bash-language-server
  npm install -g vscode-langservers-extracted
  npm install -g graphql-language-service-cli
  npm install -g svelte-language-server
  npm install -g emmet-ls
  npm install -g @prisma/language-server
  npm install -g vim-language-server

  brew install black
  brew install stylua
  brew install shfmt

  brew install rustup
  rustup install nightly
]]

shell_scripts.update_dependencies_homebrew = [[
  brew update

  brew upgrade ripgrep
  brew upgrade fd
  brew upgrade node
  brew upgrade npm
  brew upgrade fzf

  brew upgrade gcc

  brew upgrade llvm
  brew upgrade typescript-language-server
  brew upgrade pyright
  brew upgrade lua-language-server
  brew upgrade gopls
  brew upgrade tailwindcss-language-server
  brew upgrade bash-language-server
  npm update -g vscode-langservers-extracted
  npm update -g graphql-language-service-cli
  npm update -g svelte-language-server
  npm update -g emmet-ls
  npm update -g @prisma/language-server
  npm update -g vim-language-server

  brew upgrade black
  brew upgrade stylua
  brew upgrade shfmt

  brew upgrade rustup
  rustup upgrade nightly
]]

shell_scripts.install_dependencies_pacman = [[
  sudo pacman -Sy

  yes | sudo pacman -S ripgrep
  yes | sudo pacman -S fd
  yes | sudo pacman -S nodejs
  yes | sudo pacman -S npm
  yes | sudo pacman -S fzf

  yes | sudo pacman -S gcc

  yes | sudo pacman -S llvm
  yes | sudo pacman -S clang
  yes | sudo pacman -S typescript-language-server
  yes | sudo pacman -S pyright
  yes | sudo pacman -S lua-language-server
  yes | sudo pacman -S gopls
  yes | sudo pacman -S tailwindcss-language-server
  yes | sudo pacman -S bash-language-server
  yes | sudo pacman -S vscode-css-languageserver
  yes | sudo pacman -S vscode-html-languageserver
  yes | sudo pacman -S vscode-json-languageserver
  yes | sudo pacman -S svelte-language-server
  yes | sudo pacman -S graphql-client-cli
  sudo npm install -g emmet-ls
  sudo npm install -g @prisma/language-server
  sudo npm install -g vim-language-server

  yes | sudo pacman -S python-black
  yes | sudo pacman -S stylua
  yes | sudo pacman -S shfmt

  yes | sudo pacman -S rustup
  rustup install nightly
]]

shell_scripts.update_dependencies = [[
  sudo pacman -Sy

  yes | sudo pacman -S ripgrep
  yes | sudo pacman -S fd
  yes | sudo pacman -S nodejs
  yes | sudo pacman -S npm
  yes | sudo pacman -S fzf

  yes | sudo pacman -S gcc

  yes | sudo pacman -S llvm
  yes | sudo pacman -S clang
  yes | sudo pacman -S typescript-language-server
  yes | sudo pacman -S pyright
  yes | sudo pacman -S lua-language-server
  yes | sudo pacman -S gopls
  yes | sudo pacman -S tailwindcss-language-server
  yes | sudo pacman -S bash-language-server
  yes | sudo pacman -S vscode-css-languageserver
  yes | sudo pacman -S vscode-html-languageserver
  yes | sudo pacman -S vscode-json-languageserver
  yes | sudo pacman -S svelte-language-server
  yes | sudo pacman -S graphql-client-cli
  sudo npm update -g @prisma/language-server
  sudo npm update -g emmet-ls
  sudo npm update -g vim-language-server

  yes | sudo pacman -S python-black
  yes | sudo pacman -S stylua
  yes | sudo pacman -S shfmt

  yes | sudo pacman -S rustup
  rustup update nightly
]]

-- =============================================================================
-- Keymaps
-- Tags: KEY, KEYS, KEYMAP, KEYMAPS
-- =============================================================================

local keymaps_opts = { noremap = true, silent = true }

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
keymap.set('n', '<M-+>', '<cmd>resize +5<CR>', keymaps_opts)
keymap.set('n', '<M-_>', '<cmd>resize -5<CR>', keymaps_opts)
keymap.set('n', '<M-->', '<cmd>vertical resize -10<CR>', keymaps_opts)
keymap.set('n', '<M-=>', '<cmd>vertical resize +10<CR>', keymaps_opts)

-- Copy and Paste
keymap.set({ 'n', 'v' }, '<M-y>', '"+y', keymaps_opts)
keymap.set({ 'n', 'v' }, '<M-Y>', '"+Y', keymaps_opts)
keymap.set({ 'n', 'v' }, '<M-p>', '"+p', keymaps_opts)
keymap.set({ 'n', 'v' }, '<M-P>', '"+P', keymaps_opts)
keymap.set({ 'n', 'v' }, '<M-d>', '"+d', keymaps_opts)
keymap.set({ 'n', 'v' }, '<M-D>', '"+D', keymaps_opts)

-- Buffer
keymap.set('n', '<leader>bd', '<cmd>bd<CR>', keymaps_opts)

-- Cursor
local keys = ''
local number = ''
for i = 1, 199 do
  number = tostring(i)
  keys = ''
  for j = 1, #number do
    keys = keys .. middle_row_of_keyboard[tonumber(string.sub(number, j, j)) + 1]
  end
  keymap.set({ 'n', 'v', 'o' }, "'" .. keys .. '<leader>', number .. 'j', keymaps_opts)
  keymap.set({ 'n', 'v', 'o' }, '[' .. keys .. '<leader>', number .. 'k', keymaps_opts)
end

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
keymap.set('n', '<leader>oo', '<cmd>e ' .. vim.fn.stdpath('config') .. '/init.lua<CR>')

-- =============================================================================
-- Options
-- Tags: OPT, OPTS, OPTION, OPTIONS
-- =============================================================================

vim.g.encoding = 'UTF-8'

opt.autowrite = true
opt.breakindent = true -- Wrap indent to match line start
-- opt.cmdheight = 0 -- Use noice.nvim plugin, no need to display cmdline
opt.colorcolumn = '80,100' -- Line number reminder
opt.conceallevel = 2 -- Hide * markup for hold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.copyindent = true -- Copy the previous indentation on autoindenting
-- opt.cursorcolumn = true -- Highlight the text column of the cursor
opt.cursorline = true -- Highlight the text line of the cursor
opt.expandtab = true -- Use space instead of tabs
opt.fileencoding = 'utf-8' -- File content encoding for the buffer
opt.linebreak = true -- Wrap lines at 'breakat'
opt.ignorecase = true -- Ignore case
opt.list = true -- Show some hidden characters
opt.number = true
opt.pumheight = 30
-- opt.relativenumber = true
opt.scrolloff = 8 -- Lines of context
opt.shiftround = true -- Round indent
opt.shiftwidth = 4 -- Number of space inserted for indentation
opt.showmode = false -- No display mode
opt.sidescrolloff = 8 -- Columns of context
opt.smartcase = true -- Case sensitive searching
opt.smartindent = true -- Insert indents automatically
opt.smoothscroll = true
opt.softtabstop = 4
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.tabstop = 4 -- Number of spaces tabs count for
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
-- opt.virtualedit = 'block' -- Allow cursor to move where there is no text in visual block mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

if not enabled_plugins then
  vim.cmd.colorschemes('habamax')
end

-- =============================================================================
-- Commands
-- Tags: CMD, COMMAND, COMMANDS
-- =============================================================================

-- Useless
vim.cmd.cabbrev('W! w!')
vim.cmd.cabbrev('W1 w!')
vim.cmd.cabbrev('w1 w!')
vim.cmd.cabbrev('Q! q!')
vim.cmd.cabbrev('Q1 q!')
vim.cmd.cabbrev('q1 q!')
vim.cmd.cabbrev('Qa! qa!')
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

create_user_command('RunShellScript', function(t)
  if shell_scripts[t.args] then
    vim.cmd.term(shell_scripts[t.args])
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
create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.highlight.on_yank()
  end,
})

create_autocmd('User', {
  pattern = 'FileOpened',
  desc = 'Ghostty configuration file commentstring',
  callback = function()
    local buf_name = api.nvim_buf_get_name(0)
    local path = vim.fn.split(buf_name, '/')
    if path[3] == '.config' and path[4] == 'ghostty' and path[5] == 'config' then
      vim.bo.commentstring = '#%s'
    end
  end,
})

-- https://github.com/sitiom/nvim-numbertoggle/blob/main/plugin/numbertoggle.lua
create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
  pattern = '*',
  callback = function()
    if vim.o.nu and api.nvim_get_mode().mode ~= 'i' then
      vim.opt.relativenumber = true
    end
  end,
})

create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
  pattern = '*',
  callback = function()
    if vim.o.nu then
      vim.opt.relativenumber = false
      vim.cmd('redraw')
    end
  end,
})

create_autocmd('FileType', {
  pattern = { 'lua', 'json', 'json5', 'jsonc', 'lsonc', 'markdown' },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.smarttab = true
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
  callback = function(args)
    api.nvim_exec_autocmds('User', { pattern = 'FileOpened', modeline = false })
  end,
})

-- =============================================================================
-- Gui
-- Tags: GUI
-- =============================================================================

local gui_font = 'BlexMono Nerd Font Mono'
local gui_font_size = 13.5

local gui_change_font_size = function(n)
  gui_font_size = gui_font_size + n
  opt.guifont = gui_font .. ':h' .. gui_font_size
  print(gui_font_size)
end

opt.guifont = gui_font .. ':h' .. gui_font_size

keymap.set('n', '<C-=>', function()
  gui_change_font_size(0.5)
end)
keymap.set('n', '<C-->', function()
  gui_change_font_size(-0.5)
end)

-- ===== NEOVIDE =====
if vim.g.neovide then
  local neovide_transparency = 1

  local neovide_change_transparency = function(n)
    if neovide_transparency + n <= 1 and neovide_transparency + n >= 0 then
      neovide_transparency = neovide_transparency + n
      vim.g.neovide_transparency = neovide_transparency
      print(neovide_transparency)
    else
      print('transparency out of range (' .. neovide_transparency .. ')')
    end
  end

  opt.pumblend = 30
  opt.winblend = 30

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

  vim.keymap.set('n', '<C-+>', function() neovide_change_transparency(0.1) end)
  vim.keymap.set('n', '<C-_>', function() neovide_change_transparency(-0.1) end)
end

-- =============================================================================
-- Features
-- Tags: FEATURES
-- =============================================================================

-- Translate shell (trans)
local translate = function(t, to)
  vim.cmd.split()
  local text = t
  text = string.gsub(text, '"', '"' .. "'" .. '"' .. "'" .. '"')
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
local lazy_config = enabled_plugins and {
  install = { colorscheme = { 'gruvbox', 'habamax' } },
  checker = { enabled = true },
  change_detection = { notify = false },
  ui = {
    -- My font does not display the default icon properly
    icons = {
      debug = ' ',
      loaded = '',
      not_loaded = '',
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'netrwPlugin',
      },
    },
  },
} or nil

local plugins = enabled_plugins and {

  -- COLORSCHEME
  --- GRUVBOX
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    enabled = true,
    config = function()
      create_autocmd('ColorScheme', {
        pattern = '*',
        callback = function()
          if vim.g.colors_name == 'gruvbox' then
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
            set_hl(0, 'DiagnosticNumHlError', { fg = colors.red, bold = true })
            set_hl(0, 'DiagnosticNumHlWarn', { fg = colors.yellow, bold = true })
            set_hl(0, 'DiagnosticNumHlHint', { fg = colors.aqua, bold = true })
            set_hl(0, 'DiagnosticNumHlInfo', { fg = colors.blue, bold = true })

            set_hl(0, 'NoiceCmdlineIcon', { fg = colors.orange })
            set_hl(0, 'NoiceCmdlineIconLua', { fg = colors.blue })
            set_hl(0, 'NoiceCmdlineIconHelp', { fg = colors.red })

            set_hl(0, 'FzfLuaHeaderText', { fg = colors.red })
            set_hl(0, 'FzfLuaHeaderBind', { fg = colors.orange })

            set_hl(0, 'FlashLabel', { bg = colors.red, fg = colors.bg0 })

            set_hl(0, 'BlinkCmpKindClass', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindColor', { bg = colors.purple, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindConstant', { bg = colors.orange, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindConstructor', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindEnum', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindEnumMember', { bg = colors.aqua, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindEvent', { bg = colors.purple, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindField', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindFile', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindFolder', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindFunction', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindInterface', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindKeyword', { bg = colors.purple, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindMethod', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindModule', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindOperator', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindProperty', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindReference', { bg = colors.purple, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindSnippet', { bg = colors.green, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindStruct', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindText', { bg = colors.orange, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindTypeParameter', { bg = colors.yellow, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindUnit', { bg = colors.blue, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindValue', { bg = colors.orange, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindVariable', { bg = colors.orange, fg = colors.bg1 })
            set_hl(0, 'BlinkCmpKindCopilot', { bg = colors.gray, fg = colors.bg1 })
          end
        end,
      })
      local palette = require('gruvbox').palette
      require('gruvbox').setup({
        italic = {
          strings = false,
          comments = true,
        },
        overrides = {
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
          IlluminatedWordText = { underline = true },
          IlluminatedWordRead = { underline = true },
          IlluminatedWordWrite = { underline = true },

          -- gitsigns.nvim
          GitSignsCurrentLineBlame = { fg = palette.dark4 },

          -- blink.cmp
          BlinkCmpSource = { link = 'GruvboxGray' },
          BlinkCmpLabelDeprecated = { link = 'GruvboxGray' },
          BlinkCmpLabelDetail = { link = 'GruvboxGray' },
          BlinkCmpLabelDescription = { link = 'GruvboxGray' },
        },
      })
      vim.cmd.colorscheme('gruvbox')
    end,
  },

  -- MINI.STARTER
  {
    'echasnovski/mini.starter', config = function()
      local starter = require('mini.starter')
      local v = vim.version()
      local prerelease = v.api_prerelease and '(Pre-release) v' or 'v'

      local version = function()
        return 'NVIM ' .. prerelease .. tostring(vim.version())
      end

      local header = function()
        return version() .. '\n\n' ..
          'Nvim is open source and freely distributable\n' ..
          'https://neovim.io/#chat'

        -- 'This configuration\n' ..
        -- 'https://github.com/gczcn/dotfile/tree/main/nvim/.config/nvim'
      end

      local footer = function()
        return
        os.date()
      end

      local recent_files = function(n, index_h, index, current_dir, show_path)
        n = n or 5
        if current_dir == nil then current_dir = false end

        if show_path == nil then show_path = true end
        if show_path == false then show_path = function() return '' end end
        if show_path == true then
          show_path = function(path) return string.format(' (%s)', vim.fn.fnamemodify(path, ':~:.')) end
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
            local name = index_h .. (i ~= '' and (i ~= 10 and i .. ' ' or '0 ') or '') .. vim.fn.fnamemodify(f, ':t') .. show_path(f)
            i = i == '' and '' or i + 1
            table.insert(items, { action = 'edit ' .. f, name = name, section = section })
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

          -- Oil
          { name = 'e File Browser', action = ':Oil', section = 'Oil' },
          { name = 'w File Browser (Options)', action = ':Oil ' .. vim.fn.stdpath('config'), section = 'Oil' },

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
          -- starter.gen_hook.adding_bullet('│ '),
          starter.gen_hook.adding_bullet('░ '),
        },
        header = header(),
        footer = footer(),
        -- footer = '',
        query_updaters = 'abcdefghijklmnopqrstuvwxyz0123456789_-.`',
        silent = true,

      }

      starter.setup(opts)

      api.nvim_create_user_command('MiniStarterToggle', function()
        if vim.o.filetype == 'ministarter' then
          require('mini.starter').close()
        else
          require('mini.starter').open()
        end
      end, {})

      keymap.set('n', '<leader>ts', '<cmd>MiniStarterToggle<CR>')

      api.nvim_create_autocmd('User', {
        pattern = 'LazyVimStarted',
        callback = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

          local get_startuptime = function()
            return 'loaded '
              .. stats.loaded
              .. '/'
              .. stats.count
              .. ' plugins in '
              .. ms
              .. 'ms'
          end

          local ft = function()
            -- stylua: ignore
            return
              get_startuptime() .. '\n' ..
              footer()
          end

          starter.config.footer = ft

          if vim.o.filetype == 'ministarter' then
            starter.refresh()
          end
        end
      })

      -- Disable folding on Starter buffer
      vim.cmd([[ autocmd FileType Starter setlocal nofoldenable ]])
    end
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

          -- Move cursor to corresponding edge of `a` textobject
          goto_left = 'g[',
          goto_right = 'g]',
        },
      })
    end,
  },

  -- MINI.ICONS
  {
    'echasnovski/mini.icons',
    lazy = true,
    opts = {
      file = {
        ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
        ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
      },
      filetype = {
        dotenv = { glyph = '', hl = 'MiniIconsYellow' },
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
  {
    'echasnovski/mini.pairs',
    event = { 'InsertEnter', 'CmdlineEnter' },
    config = function()
      require('mini.pairs').setup({
        -- modes = { insert = true, command = true, terminal = false },
      })
    end,
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

  -- OIL
  {
    'stevearc/oil.nvim',
    keys = {
      {
        '<leader>e',
        function()
          if vim.o.filetype == 'oil' then
            require('oil').close()
          else
            require('oil').open()
          end
        end,
        mode = 'n',
      },
      {
        '<leader>E',
        function()
          require('oil').open(vim.fn.stdpath('config'))
        end,
        mode = 'n',
      },
    },
    cmd = 'Oil',
    init = function()
      local oil_open_folder = function(path) require('oil').open(path) end
      autocmd_attach_file_browser('oil', oil_open_folder)
    end,
    config = function()
      _G.get_oil_winbar = function()
        local dir = require('oil').get_current_dir()
        if dir then
          return vim.fn.fnamemodify(dir, ':~')
        else
          -- If there is no current directory (e.g. over ssh), just show the buffer name
          return api.nvim_buf_get_name(0)
        end
      end
      require('oil').setup({
        -- columns = {
        --   'icon',
        --   'permissions',
        --   'size',
        --   -- 'mtime',
        -- },
        win_options = {
          winbar = '%!v:lua.get_oil_winbar()',
        },
        default_file_explorer = true,
        view_options = {
          show_hidden = true,
        },
        confirmation = {
          border = plugins_config.border,
        },
      })
    end,
  },

  -- NEOTREE (Disabled)
  {
    'nvim-neo-tree/neo-tree.nvim',
    enabled = false,
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'echasnovski/mini.icons',
      'MunifTanjim/nui.nvim',
      -- '3rd/image.nvim', -- Optional image support in preview window: See `# Preview Mode` for more information

      {
        's1n7ax/nvim-window-picker',
        version = '2.*',
        config = function()
          require 'window-picker'.setup({
            filter_rules = {
              include_current_win = false,
              autoselect_one = true,
              -- filter using buffer options
              bo = {
                -- if the file type is one of following, the window will be ignored
                filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
                -- if the buffer type is one of following, the window will be ignored
                buftype = { 'terminal', 'quickfix' },
              },
            },
          })
        end,
      },
    },
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<CR>', desc = 'Explorer NeoTree (user dir)', remap = true },
      { '<leader>E', '<cmd>Neotree dir=%:p:h toggle<CR>', desc = 'Explorer NeoTree (%f)',       remap = true },
      {
        '<leader>ge',
        function()
          require('neo-tree.command').execute({ source = 'git_status', toggle = true })
        end,
        desc = 'Git explorer',
      },
      {
        '<leader>be',
        function()
          require('neo-tree.command').execute({ source = 'buffers', toggle = true })
        end,
        desc = 'Buffer explorer',
      },
    },
    init = function()
      -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
      -- because `cwd` is not set up properly.
      api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup('Neotree_start_directory', { clear = true }),
        desc = 'Start Neo-tree with directory',
        once = true,
        callback = function()
          if package.loaded['neo-tree'] then
            return
          else
            local stats = vim.uv.fs_stat(vim.fn.argv(0))
            if stats and stats.type == 'directory' then
              require('neo-tree')
            end
          end
        end,
      })
    end,
    config = function()
      require('neo-tree').setup({
        event_handlers = {
          {
            event = 'vim_buffer_enter',
            handler = function()
              if vim.bo.filetype == 'neo-tree' then
                opt.number = true
                opt.cursorcolumn = false
                -- opt.relativenumber = true
              end
            end,
          },
        },
        popup_border_style = 'single',
        window = {
          mappings = {
            ['e'] = 'none',
            ['o'] = 'open',
            ['h'] = { 'show_help', nowait = false, config = { title = 'Order by', prefix_key = 'o' } },
          },
        },
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hijack_netrw_behavior = 'open_current'
          },
        },
      })
    end
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
          border = plugins_config.border,
          preview = {
            border = plugins_config.border,
          },
          backdrop = 100,
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
    keys = {
      { '<leader>fo', '<cmd>Telescope emoji<CR>' },
      { '<leader>fg', '<cmd>Telescope glyph<CR>' },
      { '<leader>fe', '<cmd>Telescope file_browser<CR>' },
      { '<leader>fu', '<cmd>Telescope undo<CR>' },
      { '<leader>fp', '<cmd>Telescope neoclip<CR>' },
      { '<leader>ft', '<cmd>Telescope nerdy<CR>' },
    },
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
      '2kabhishek/nerdy.nvim',
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      local get_borderchars_table = function()
        local b = plugins_config.border
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
        extensions = {
          file_browser = {
            hijack_netrw = true,
            hidden = { file_browser = true, folder_browser = true },
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
    dependencies = {
      'kevinhwang91/promise-async'
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
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end

      require('ufo').setup({
        fold_virt_text_handler = handler,
        provider_selector = function(bufnr, filetype, buftype)
          return {'treesitter', 'indent'}
        end
      })
    end
  },

  -- VIM-ILLUMINATE, WORD
  {
    'rrethy/vim-illuminate',
    event = 'User FileOpened',
    opts = {
      delay = 0,
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

      local function map(key, dir, buffer)
        keymap.set('n', key, function()
          require('illuminate')['goto_' .. dir .. '_reference'](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' reference', buffer = buffer })
      end

      map(']]', 'next')
      map('[[', 'prev')

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd('FileType', {
        pattern = '*',
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map(']]', 'next', buffer)
          map('[[', 'prev', buffer)
        end,
      })

      vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
        pattern = '*',
        callback = function()
          require('illuminate').resume()
        end,
      })

      vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
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
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    event = 'User FileOpened',
    opts = {},
    -- stylua: ignore
    keys = {
      { ']c', function() require('todo-comments').jump_next() end, desc = 'Next Todo Comment' },
      { '[c', function() require('todo-comments').jump_prev() end, desc = 'Previous Todo Comment' },
      -- { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'Todo (Trouble)' },
      -- { '<leader>xT', '<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>', desc = 'Todo/Fix/Fixme (Trouble)' },
      { '<leader>ft', '<cmd>TodoTelescope<cr>', desc = 'Todo' },
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

  -- COKELINE, TABBAR
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

      local colors = {
        default = 'gruvbox',
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
              normal_num = { bg = '#928374', fg = '#282828', bold = true },
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
        if colors[vim.g.colors_name] then
          return colors[vim.g.colors_name][(vim.o.background == 'dark' or vim.o.background == 'light') and vim.o.background or 'dark']
        else
          return colors[colors.default][(vim.o.background == 'dark' or vim.o.background == 'light') and vim.o.background or 'dark']
        end
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
      keymap.set('n', ']0', '<cmd>LualineBuffersJump $<CR>', opts)
      for i = 1, 9 do
        keymap.set('n', (']%s'):format(middle_row_of_keyboard[i + 1]), ('<Plug>(cokeline-focus-%s)'):format(i), opts)
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
              if is_picking_focus() or is_picking_close() then
                return ' ' .. buffer.pick_letter
              end
              return ' ' .. buffer.devicon.icon
            end,
            style = function(_)
              return (is_picking_focus() or is_picking_close()) and 'italic,bold' or nil
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
              return buffer.is_modified and '* ' or ''
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
        },
        tabs = {
          placement = 'right',
          components = {
            {
              text = function(tabpage)
                local name = get_tab_name(tabpage.number)
                if name then
                  local icon = ''
                  local icon_filename, _ = require('nvim-web-devicons').get_icon(name)
                  if icon_filename then
                    icon = icon_filename .. ' '
                  else
                    local icon_filetype, _ = require('nvim-web-devicons').get_icon_by_filetype(
                      api.nvim_buf_call(api.nvim_win_get_buf(api.nvim_tabpage_get_win(tabpage.number)), function()
                        return vim.o.filetype
                      end))
                    icon = icon_filetype and icon_filetype .. ' ' or ''
                  end
                  return ' ' .. name .. ' ' .. icon
                end
                return ''
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
                vim.ui.input({ prompt = 'Quit Neovim? Y/n' }, function(input)
                  if input == '' or string.lower(input) == 'y' then
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
    dependencies = { 'echasnovski/mini.icons' },
    config = function()
      local get_date = function()
        return os.date('%D %R')
      end

      local lsp_clients = function()
        local bufnr = api.nvim_get_current_buf()

        local clients = vim.lsp.get_clients({ buffer = bufnr })
        if next(clients) == nil then
          return ''
        end

        local c = {}
        for _, client in pairs(clients) do
          table.insert(c, client.name)
        end
        return ' ' .. table.concat(c, ', ')
      end

      require('lualine').setup({
        options = {
          component_separators = '',
          section_separators = { left = '', right = '' },
          disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'ministarter' } },
          globalstatus = true,
        },
        sections = {
          lualine_a = { simple_mode },
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
                return { fg = get_hl('Statement') }
              end
            },

            -- stylua: ignore
            {
              function() return require('noice').api.status.mode.get() end,
              cond = function() return package.loaded['noice'] and require('noice').api.status.mode.has() end,
              color = function()
                return { fg = get_hl('Constant') }
              end
            },
            lsp_clients,
            'tabnine',
            'hostname',
            'fileformat',
          },
          lualine_y = {
            { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
            { 'location', padding = { left = 0, right = 1 } },
          },
          lualine_z = { get_date },
        },
      })
    end,
  },

  -- TREESITTER
  {
    'nvim-treesitter/nvim-treesitter',
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
      -- context
      { '[c', function() require('treesitter-context').go_to_context() end, mode = 'n' },
    },
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-treesitter-context',
      'HiPhish/rainbow-delimiters.nvim',
    },
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

  -- COMMENT
  -- NOTE: neovim nightly version already has built-in commenting.
  {
    'numToStr/Comment.nvim',
    keys = {
      { 'gc', mode = { 'n', 'v' } },
      { 'gb', mode = { 'n', 'v' } },

      -- normal mode
      { 'gcc', mode = 'n' },
      { 'gbc', mode = 'n' },
      { 'gco', mode = 'n' },
      { 'gcO', mode = 'n' },
      { 'gcA', mode = 'n' },
    },
    config = function() require('Comment').setup() end,
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
      local hl = vim.api.nvim_set_hl
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
      -- labels = 'asdfghjklqwertyuiopzxcvbnm',
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

  -- HLSLENS, SEARCH
  {
    'kevinhwang91/nvim-hlslens',
    event = { 'User FileOpened', 'CmdlineEnter' },
    config = function()
      require('scrollbar.handlers.search').setup()

      local kopts = { noremap = true, silent = true }

      keymap.set('n', 'j', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], kopts)
      keymap.set('n', 'J', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], kopts)
      keymap.set('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      keymap.set('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
      keymap.set('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      keymap.set('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)
    end,
  },

  -- SCROLLBAR
  {
    'petertriho/nvim-scrollbar',
    event = 'User FileOpened',
    dependencies = {
      'lewis6991/gitsigns.nvim',
    },
    config = function()
      local change_highlight = function()
        local set_hl = api.nvim_set_hl
        if vim.g.colors_name == 'gruvbox' then
          -- local palette = require('gruvbox').palette
          local bg = get_hl('GruvboxBg2')
          set_hl(0, 'ScrollbarHandle', { bg = bg, fg = get_hl('GruvboxGreen') })

          set_hl(0, 'ScrollbarCursor', { bg = bg, fg = get_hl('GruvboxGreen') })
          set_hl(0, 'ScrollbarCursorHandle', { bg = bg, fg = get_hl('GruvboxGreen') })
          set_hl(0, 'ScrollbarSearch', { fg = get_hl('GruvboxOrange') })
          set_hl(0, 'ScrollbarSearchHandle', { bg = bg, fg = get_hl('GruvboxOrange') })
          set_hl(0, 'ScrollbarErrorHandle', { bg = bg, fg = get_hl('GruvboxRed') })
          set_hl(0, 'ScrollbarWarnHandle', { bg = bg, fg = get_hl('GruvboxYellow') })
          set_hl(0, 'ScrollbarInfoHandle', { bg = bg, fg = get_hl('GruvboxBlue') })
          set_hl(0, 'ScrollbarHintHandle', { bg = bg, fg = get_hl('GruvboxAqua') })
          set_hl(0, 'ScrollbarMiscHandle', { bg = bg, fg = get_hl('GruvboxFg1') })
          set_hl(0, 'ScrollbarGitDeleteHandle', { bg = bg, link = 'ScrollbarErrorHandle' })
          set_hl(0, 'ScrollbarGitAddHandle', { bg = bg, fg = get_hl('GruvboxGreen') })
          set_hl(0, 'ScrollbarGitChangeHandle', { bg = bg, fg = get_hl('GruvboxOrange') })
        elseif vim.g.colors_name == 'onedark' then
          set_hl(0, 'ScrollbarHandle', { bg = '#373d49', fg = '#4966A0' })
          set_hl(0, 'ScrollbarCursor', { bg = '#373d49', fg = '#4966A0' })
          set_hl(0, 'ScrollbarCursorHandle', { bg = '#373d49', fg = '#4966A0' })
        else
          set_hl(0, 'ScrollbarHandle', { link = 'Pmenu' })
        end
      end

      require('scrollbar').setup({
        marks = {
          Cursor = { text = '▐' },
          Search = { text = { '─', '═' }, },
          Error = { text = { '─', '═' }, },
          Warn = { text = { '─', '═' }, },
          Info = { text = { '─', '═' }, },
          Hint = { text = { '─', '═' }, },
          Misc = { text = { '─', '═' }, },
        },
        excluded_filetypes = {
          'ministarter',
          'blink-cmp-menu',
          'TelescopePrompt',
          'TelescopeResults',
          'TelescopePreview',
          'dropbar_menu',
        },
        handlers = {
          gitsigns = true,
        },
      })
      change_highlight()
      api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = function()
          change_highlight()
        end
      })
    end,
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

  -- CODERUNNER
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
              -- 'gcc $fileName -o',
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

  -- INDENT
  --- INDENT-BLANKLINE
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = 'User FileOpened',
    opts = {
      indent = {
        char = '▏',
        tab_char = '▏',
      },
      scope = { enabled = false },
    },
  },

  --- MINI.INDENTSCOPE
  {
    'echasnovski/mini.indentscope',
    event = 'User FileOpened',
    init = function()
      create_autocmd('FileType', {
        pattern = {
          'help',
          'alpha',
          'dashboard',
          'starter',
          'neo-tree',
          'Trouble',
          'trouble',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'lazyterm',
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
    config = function()
      require('mini.indentscope').setup({
        -- symbol = '│',
        symbol = '▏',
        options = {
          indent_at_cursor = false,
        },
        draw = {
          delay = 0,
          animation = require('mini.indentscope').gen_animation.none(),
        },
        mappings = {
          -- Textobjects
          object_scope = 'kk',
          object_scope_with_border = 'ak',

          -- Motions (jump to respective border line; if not present - body line)
          goto_top = '[i',
          goto_bottom = ']i',
        },
      })
    end,
  },

  -- LEARN
  --- PRECOGNITION
  {
    'tris203/precognition.nvim',
    event = { 'VeryLazy', 'User FileOpened', 'BufAdd' },
    keys = {
      { '<leader>ap', '<cmd>Precognition peek<CR>', mode = 'n' }
    },
    opts = {
      startVisible = false,
      highlightColor = { link = 'Comment' },
      hints = {
        Caret = { text = '|' },
        Dollar = { text = 'I' },
        Zero = { text = 'N' },
        e = { text = 'h' },
        E = { text = 'H' },
      },
    },
  },

  -- SUDA, SUDO
  {
    'lambdalisue/vim-suda',
    event = { 'VeryLazy', 'User FileOpened' },
    cmd = { 'SudaWrite', 'SudaRead' },
    config = function()
      vim.cmd.cabbrev('ww SudaWrite')
      vim.cmd.cabbrev('wwr SudaRead')
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
          cmdline = { pattern = '^:', icon = '>', lang = 'vim' },
          search_down = { kind = "search", pattern = "^/", icon = " Up", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " Down", lang = "regex" },
          -- filter = { pattern = "^:%s*!", icon = " $", lang = "bash" },
          -- lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = " ", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "?" },
          -- input = { view = "cmdline", icon = " 󰥻 " },
        },
        -- view = 'cmdline',
      },
      messages = {
        view_search = false,
      },
      views = {
        cmdline_popup = { border = { style = 'single', } },
        cmdline_input = { border = { style = 'single', } },
        confirm = { border = { style = 'single', } },
        popup_menu = { border = { style = 'single', } },
        -- hover = { border = { style = 'single', padding = { 0, 2 } } },
      },
      presets = {
        inc_rename = true,
        bottom_search = true,
        -- command_palette = true,
        long_message_to_split = true,
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

      keymap.set('n', '<leader>fn', Snacks.notifier.show_history)
      keymap.set('n', '<leader>hn', Snacks.notifier.hide)
      keymap.set('n', '<leader>ar', Snacks.rename.rename_file)
    end,
  },

  -- COPILOT
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    enabled = enabled_copilot,
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
    enabled = enabled_tabnine,
    build = './dl_binaries.sh',
    config = function()
      require('tabnine').setup({
        disable_auto_comment = true,
        accept_keymap = '<M-a>',
        dismiss_keymap = '<C-]>',
        debounce_ms = 800,
        suggestion_color = { gui = require('utils.get_hl')('Comment'), cterm = 244 },
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

          local function map(mode, l, r, desc)
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

  -- LSP
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'echasnovski/mini.icons',
      'lewis6991/gitsigns.nvim',
      {
        'smjonas/inc-rename.nvim',
        config = function()
          require('inc_rename').setup()
        end,
      },
    },
    config = function()
      local lspconfig = require('lspconfig')
      -- local util = require('lspconfig.util')
      local opts = { noremap = true, silent = true }
      local on_attach = function(_, bufnr)
        opts.buffer = bufnr

        -- set keybinds
        opts.desc = 'Show LSP references'
        keymap.set('n', 'gR', '<cmd>FzfLua lsp_references<CR>', opts) -- show definition, references

        opts.desc = 'Go to declaration'
        keymap.set('n', 'gD', vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = 'Show LSP definitions'
        keymap.set('n', 'gd', '<cmd>FzfLua lsp_definitions<CR>', opts) -- show lsp definitions

        opts.desc = 'Show LSP implementations'
        keymap.set('n', 'gi', '<cmd>FzfLua lsp_implementations<CR>', opts) -- show lsp implementations

        opts.desc = 'Show LSP type definitions'
        keymap.set('n', 'gT', '<cmd>FzfLua lsp_typedefs<CR>', opts) -- show lsp type definitions

        opts.desc = 'See available code actions'
        keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = 'Smart rename'
        -- keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        keymap.set('n', '<leader>rn', function()
          return ':IncRename ' .. vim.fn.expand('<cword>')
        end, { noremap = true, expr = true })

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

      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.HINT] = '',
            [vim.diagnostic.severity.INFO] = '',
          },
          numhl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticNumHlError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticNumHlWarn',
            [vim.diagnostic.severity.HINT] = 'DiagnosticNumHlHint',
            [vim.diagnostic.severity.INFO] = 'DiagnosticNumHlInfo',
          },
        },
        -- virtual_text = {
        --   prefix = '󰝤',
        -- },
        severity_sort = true,
      })

      local lsp_default_config = function()
        return {
          capabilities = capabilities(),
          on_attach = on_attach,
        }
      end

      -- configure html server
      lspconfig['html'].setup(lsp_default_config())

      -- configure typescript server with plugin
      lspconfig['ts_ls'].setup(lsp_default_config())

      -- configure css server
      lspconfig['cssls'].setup(lsp_default_config())

      -- configure tailwindcss server
      lspconfig['tailwindcss'].setup(lsp_default_config())

      -- configure svelte server
      lspconfig['svelte'].setup({
        capabilities = capabilities(),
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)

          vim.api.nvim_create_autocmd('BufWritePost', {
            pattern = { '*.js', '*.ts' },
            callback = function(ctx)
              if client.name == 'svelte' then
                client.notify('$/onDidChangeTsOrJsFile', { uri = ctx.file })
              end
            end,
          })
        end,
      })

      -- configure prisma orm server
      lspconfig['prismals'].setup(lsp_default_config())

      -- configure graphql language server
      local graphql_config = lsp_default_config()
      graphql_config['filetypes'] = { 'graphql', 'gql', 'svelte', 'typescriptreact', 'javascriptreact' }

      lspconfig['graphql'].setup(graphql_config)

      -- configure emmet language server
      local emmet_config = lsp_default_config()
      emmet_config['filetypes'] = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less', 'svelte' }

      lspconfig['emmet_ls'].setup(emmet_config)

      -- configure python server
      lspconfig['pyright'].setup(lsp_default_config())

      -- configure lua server (with special settings)
      lspconfig['lua_ls'].setup({
        capabilities = capabilities(),
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
      lspconfig['gopls'].setup(lsp_default_config())

      -- configure Bash language server
      lspconfig['bashls'].setup({
        capabilities = capabilities(),
        on_attach = on_attach,
        cmd = { 'bash-language-server', 'start' },
      })

      lspconfig['vimls'].setup(lsp_default_config())

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
      --   capabilities = capabilities(),
      --   on_attach = on_attach,
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
      local ls = require("luasnip")

      keymap.set({"i"}, "<C-k>", function() ls.expand() end, {silent = true})
      keymap.set({"i", "s"}, "<C-l>", function() ls.jump( 1) end, {silent = true})
      keymap.set({"i", "s"}, "<C-j>", function() ls.jump(-1) end, {silent = true})

      keymap.set({"i", "s"}, "<C-f>", function()
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
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- BLINK.CMP
  {
    'saghen/blink.cmp',
    enabled = true,
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      'rafamadriz/friendly-snippets',
      'L3MON4D3/LuaSnip',
      { 'giuxtaposition/blink-cmp-copilot', enabled = enabled_copilot },
      { 'zbirenbaum/copilot.lua', enabled = enabled_copilot },
      'moyiz/blink-emoji.nvim',
      'folke/lazydev.nvim',

      -- nvim-cmp sources
      { 'Saghen/blink.compat', opts = { impersonate_nvim_cmp = true } },
      -- { 'tzachar/cmp-tabnine', enabled = enabled_tabnine, build = './install.sh' },
    },
    build = 'rustup run nightly cargo build --release',
    -- build = 'cargo build --release',
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()

      local get_default_sources = function()
        local sources = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'emoji' }

        if enabled_copilot then
          table.insert(sources, 'copilot')
        end

        -- if enabled_tabnine then
        --   table.insert(sources, 'cmp_tabnine')
        -- end

        return sources
      end

      local opts = {
        appearance = {
          -- use_nvim_cmp_as_default = true,
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
          ['<M-y>'] = { 'accept' },
          ['<Up>'] = { 'fallback' },
          ['<Down>'] = { 'fallback' },
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
            draw = {
              padding = { 0, 1 },
              treesitter = { 'lsp', 'copilot', 'cmp_tabnine', 'snippets' },
              columns = {
                { 'kind_icon' },
                { 'label', 'label_description', gap = 1 },
                -- { 'kind_icon', 'kind', gap = 1 },
                { 'source_name' },
              },
              components = {
                kind_icon = {
                  ellipsis = false,
                  text = function(ctx)
                    return ' ' .. ctx.kind_icon .. ' '
                  end,
                  highlight = function(ctx)
                    return require('blink.cmp.completion.windows.render.tailwind').get_hl(ctx)
                      or 'BlinkCmpKind' .. ctx.kind
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
            -- border = 'single',
            winblend = vim.o.pumblend,
            max_height = 30,
          },
        },
        snippets = { preset = 'luasnip' },
        sources = {
          default = get_default_sources(),
          providers = {
            lazydev = {
              name = 'lazydev',
              module = 'lazydev.integrations.blink',
              -- make lazydev completions top priority (see `:h blink.cmp`)
              score_offset = 100,
            },
            emoji = {
              module = 'blink-emoji',
              name = 'Emoji',
              score_offset = 15, -- Tune by preference
              opts = { insert = true }, -- Insert emoji (default) or complete its name
            },
          },
        },
      }

      if enabled_copilot then
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
if enabled_plugins then
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
  opt.winblend = 15
  opt.pumblend = 15
  opt.signcolumn = 'auto'
  opt.foldcolumn = '1' -- Using ufo provider need a large value, feel free to decrease the value
  opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
  opt.foldlevelstart = 99
  opt.foldenable = true

  -- My font does not display the default icon properly.
  vim.diagnostic.config({
    virtual_text = {
      prefix = '󰝤',
    },
  })

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
