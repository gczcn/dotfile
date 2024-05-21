local autocmd = vim.api.nvim_create_autocmd

-- Line breaks are not automatically commented
autocmd('FileType', {
  pattern = '*',
  callback = function ()
    vim.cmd('setlocal formatoptions-=c formatoptions-=r formatoptions-=o')
  end
})

-- Highlight when copying
autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function ()
    vim.highlight.on_yank()
  end
})

autocmd('FileType', {
  pattern = { 'json', 'lsonc', 'markdown' },
  callback = function()
    vim.wo.conceallevel = 0
  end
})

-- Events

-- user event that loads after UIEnter + only if file buf is there
autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("NvFilePost", { clear = true }),
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    local buftype = vim.api.nvim_buf_get_option(args.buf, "buftype")

    if not vim.g.ui_entered and args.event == "UIEnter" then
      vim.g.ui_entered = true
    end

    if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
      vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
      vim.api.nvim_del_augroup_by_name "NvFilePost"

      vim.schedule(function()
        vim.api.nvim_exec_autocmds("FileType", {})

        if vim.g.editorconfig then
          require("editorconfig").config(args.buf)
        end
      end, 0)
    end
  end,
})
