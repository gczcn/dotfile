vim.g.encoding = 'UTF-8'

local opt = vim.opt

opt.autowrite = true -- enable autowrite
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
opt.foldcolumn = '1' -- Show foldcolumn
opt.foldenable = true -- Enable fold
opt.foldlevel = 99 -- Set high foldlevel
-- opt.foldlevelstart = 99 -- Start with all code unfolded
opt.ignorecase = true -- Ignore case
opt.linebreak = true -- Wrap lines at 'breakat'
opt.list = true -- Show some hidden characters
opt.number = true -- Show number column
opt.scrolloff = 8 -- Lines of context
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Number of space inserted for indentation
opt.showmode = false -- No display mode
opt.sidescrolloff = 8 -- Columns of context
opt.smartcase = true -- Case sensitive searching
opt.smartindent = true -- Insert indents automatically
opt.smoothscroll = true
opt.softtabstop = 2
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

-- There are additional settings in the lazy_init.lua file
