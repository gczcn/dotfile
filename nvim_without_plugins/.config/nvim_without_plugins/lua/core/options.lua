-- =========
-- Options
-- =========

vim.g.encoding = 'UTF-8'

local opt = vim.opt

opt.autowrite = true
opt.breakindent = true -- Wrap indent to match line start
opt.colorcolumn = '80' -- Line number reminder
opt.completeopt = 'menu,popup,menuone,noselect'
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
opt.listchars =
  { tab = '> ', trail = '-', extends = '>', precedes = '<', nbsp = '+' }
opt.maxmempattern = 5000
opt.number = true
opt.pumblend = 10
opt.pumheight = 30
opt.scrolloff = 8 -- Lines of context
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Number of space inserted for indentation
opt.shortmess = vim.o.shortmess .. 'I' -- Don't give the intro messages when starting Neovim
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
