local g = vim.g

local font = 'Sarasa Term SC'
local symbol = 'JetBrainsMono Nerd Font Mono'
local font_size = 12

vim.o.guifont = font .. ',' .. symbol .. ':h' .. font_size
vim.o.pumblend = 30
vim.o.winblend = 30

g.neovide_floating_blur_amount_x = 1.5
g.neovide_floating_blur_amount_y = 1.5
g.neovide_scroll_animation_length = 0.3
g.neovide_hide_mouse_when_typing = true
g.neovide_unlink_border_highlights = true
g.neovide_confirm_quit = true
g.neovide_cursor_animate_command_line = true
g.neovide_cursor_unfocused_outline_width = 0.1
g.neovide_remember_window_size = true
g.neovide_input_macos_option_key_is_meta = 'only_left'
