-- gczcn's neovim configuration without any plugins
-- Requires neovim 0.11 or higher
if vim.fn.has('nvim-0.11') == 1 then
	require('global_config')

	require('basic.keymaps')
	require('basic.options')

	-- Colorscheme
	vim.api.nvim_create_autocmd('ColorScheme', {
		group = vim.api.nvim_create_augroup('custom_highlights_gruvbox', {}),
		pattern = 'gruvbox',
		callback = function()
			local colors = require('colorschemes.gruvbox').get_colors()
			local set_hl = vim.api.nvim_set_hl
		end,
	})

	require('colorschemes.gruvbox').setup({
	})

	vim.cmd.colorscheme('gruvbox')
else
	vim.notify('Error: Requires neovim 0.11 or higher', vim.log.levels.ERROR)
	vim.cmd.q()
end
