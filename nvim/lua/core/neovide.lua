local font = 'FiraCode Nerd Font Mono'
local symbol = 'FiraCode Nerd Font Mono'
local font_size = 11

vim.o.guifont = font .. ',' .. symbol .. ':h' .. font_size
vim.o.pumblend = 30
vim.o.winblend = 30

local neovide_options = {
  floating_blur_amount_x = 1.5,
  floating_blur_amount_y = 1.5,
  scroll_animation_length = 0.15,
  hide_mouse_when_typing = true,
  unlink_border_highlights = true,
  confirm_quit = true,
  cursor_animate_command_line = true,
  cursor_unfocused_outline_width = 0.1,
  cursor_vfx_mode = 'pixiedust',
  remember_window_size = true,
  input_macos_alt_is_meta = true,
  scroll_animation_length = 0.15,
  hide_mouse_when_typing = true,
  unlink_border_highlights = true,
  confirm_quit = true,
  cursor_animate_command_line = true,
  cursor_unfocused_outline_width = 0.1,
  cursor_vfx_mode = 'pixiedust',
  remember_window_size = true,
  input_macos_alt_is_meta = true,
}

for key, value in pairs(neovide_options) do
  vim.g['neovide_' .. key] = value
end
