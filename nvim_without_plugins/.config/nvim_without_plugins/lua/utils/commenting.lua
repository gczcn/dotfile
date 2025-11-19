-- ============================================================
-- Commenting Utils
-- Fill the gaps in neovim's builtin commenting functionality
-- ============================================================

---@class CommentingUtils
---@field operator_rhs function
---@field newline function
---@field line_end function
---@field toggle_line function
local Commenting = {}

local api = vim.api

-- See vim/_defaults.lua
---@return string
Commenting.operator_rhs = function()
  return require('vim._comment').operator() .. '_'
end

-- Add comment on a new line
---@param key string
Commenting.newline = function(key)
  vim.cmd(
    string.format(
      [[noautocmd exe "norm! %s\<esc>cc.\<esc>%sf.x"]],
      key,
      Commenting.operator_rhs()
    )
  )
  local line = api.nvim_get_current_line()
  local cursor_loc = api.nvim_win_get_cursor(0)
  vim.fn.feedkeys(
    string.sub(line, cursor_loc[2] + 1, -1):find('%S') and 'i' or 'a',
    'n'
  )
end

-- Add comment at the end of line
Commenting.line_end = function()
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
    Commenting.newline('cc')
  end
end

-- Toggle comment line
Commenting.toggle_line = function()
  local line = api.nvim_get_current_line()
  if line:find('%S') then
    vim.fn.feedkeys(Commenting.operator_rhs(), 'n')
  else
    Commenting.newline('cc')
  end
end

return Commenting
