-- =============================================================================
-- My Simple Neovim Configuration
-- https://github.com/gczcn/dotfile/
-- Author: Zixuan Chu <494353540@qq.com>
--
-- Dependencies:
--   Neovim >= 0.11
-- =============================================================================

-- =============================================================================
-- Global vars
-- Tags: VAR, VARS, GLOBAL
-- =============================================================================

local api = vim.api
local keymap = vim.keymap
local opt = vim.opt
local create_autocmd = api.nvim_create_autocmd
local create_augroup = api.nvim_create_augroup
local create_user_command = api.nvim_create_user_command

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
