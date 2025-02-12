local api = vim.api
local Commenting = {}

local operator_rhs = function()
	return require('vim._comment').operator() .. '_'
end

-- Add comment at the end of line.
Commenting.line_end = function()
	local line = api.nvim_get_current_line()
	local commentstring = vim.bo.commentstring
	api.nvim_feedkeys(string.format('A%s%s', line:find('%S') and ' ' or '', string.format(commentstring, '')), 'n', false)
end

-- Add comment on the line above.
Commenting.above = function()
	vim.cmd(string.format([[noautocmd exe "norm O.\<esc>%s$x" | call feedkeys('a')]], operator_rhs()))
end

-- Add comment on the line below
Commenting.below = function()
	vim.cmd(string.format([[noautocmd exe "norm o.\<esc>%s$x" | call feedkeys('a')]], operator_rhs()))
end

-- Toggle comment line
Commenting.toggle_line = function()
	local line = api.nvim_get_current_line()
	if line:find('%S') then
		api.nvim_feedkeys(operator_rhs(), 'n', false)
	else
		vim.cmd(string.format([[noautocmd exe "norm cc.\<esc>%s$x" | call feedkeys("a")]], operator_rhs()))
	end
end

return Commenting
