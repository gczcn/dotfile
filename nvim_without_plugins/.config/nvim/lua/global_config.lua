---@class GlobalConfig
---@field keyboard_layout 'colemak' | 'qwerty'
---@field middle_row_of_keyboard { [string]: string[] }
_G.GlobalConfig = {
	-- Decide whether to redefine some keys to accommodate different keyboard layouts
	-- Possible value: 'colemak' | 'qwerty
	keyboard_layout = 'colemak',

	-- Use the middle row of the keyboard instead of the number keys
	middle_row_of_keyboard = {
		colemak = { 'o', 'a', 'r', 's', 't', 'd', 'h', 'n', 'e', 'i' },
		qwerty  = { ';', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l' },
	},
}
