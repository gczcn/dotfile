local options = {
  fileencoding   = 'UTF-8',                             -- file content encoding for the buffer
  autowrite      = true,                                -- enable autowrite
  number         = true,                                -- show numbercolumn
  relativenumber = true,                                -- show relative numbercolumn
  completeopt    = { 'menu', 'menuone', 'noselect' },   -- options for insert mode completion
  cursorline     = true,                                -- highlight the text line of the cursor
  cursorcolumn   = true,                                -- highlight the text column of the cursor
  scrolloff      = 8,                                   -- lines of context
  sidescrolloff  = 8,                                   -- columns of context
  wrap           = false,                               -- disable line wrap
  tabstop        = 2,                                   -- number of spaces tabs count for
  softtabstop    = 2,
  shiftwidth     = 2,                                   -- number of space inserted for indentation
  shiftround     = true,                                -- round indent
  expandtab      = true,                                -- use spaces instead of tabs
  autoindent     = true,                                -- enable autoindent
  breakindent    = true,                                -- wrap indent to match line start
  smartindent    = true,                                -- insert indents automatically
  ignorecase     = true,                                -- ignore case
  smartcase      = true,                                -- case sensitive searching
  incsearch      = true,                                -- enable incremental search
  whichwrap      = 'b,s,<,>,[,],h,l',                   -- move the beginning and end of a line across lines
  autoread       = true,
  mouse          = 'a',                                 -- enable mouse support
  updatetime     = 100,                                 -- save swap file and trigger CursorHold
  splitbelow     = true,                                -- put new windows below current
  splitright     = true,                                -- put new windows right of current
  list           = true,
  showmode       = false,                               -- disable showing modes in command line
  conceallevel   = 2,                                   -- hide * markup for bold and italic, but not markers with substitutions
  confirm        = true,                                -- confirm to save changes before exiting modified buffer
  colorcolumn    = '80,100',                            -- line number reminder
  copyindent     = true,                                -- copy the previous indentation on autoindenting
  history        = 300,
  linebreak      = true,                                -- wrap lines at 'breakat'
  undofile       = true,
  winminwidth    = 5,                                   -- minimum window width
  smoothscroll   = true,
  fillchars      = { foldopen = '', foldclose = '' },
  laststatus     = 0,                                   -- Don't show status line until status line plugin is loaded
  spell          = false,
  spelllang      = { 'en_us' },
}

if vim.g.setup_mode ~= 'clean' then
  vim.opt.pumblend = 15 -- set popup menu transparency
  vim.opt.winblend = 15 -- set floatwindow menu transparency
  vim.opt.signcolumn = 'yes' -- always show the sign column
end

if vim.g.setup_mode == 'default' then
  vim.opt.foldenable = true -- enable fold
  vim.opt.foldlevel = 99 -- set high foldlevel
  vim.opt.foldlevelstart = 99 -- start with all code unfolded
  vim.opt.foldcolumn = '1' -- show foldcolumn
  vim.opt.cmdheight = 0 -- Use noice.nvim plugin, no need to display cmdline
end

local global = {
  encoding = 'UTF-8',
  enabled_tabnine = true   -- If you don't use tabnine, you can set it to false
}

-- settings
for key, value in pairs(options) do
  vim.opt[key] = value
end

for key, value in pairs(global) do
  vim.g[key] = value
end
