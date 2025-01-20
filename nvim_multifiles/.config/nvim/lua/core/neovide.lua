local g = vim.g

local transparency = 1

local change_transparency = function(n)
  if transparency + n <= 1 and transparency + n >= 0 then
    transparency = transparency + n
    g.neovide_transparency = transparency
    print(transparency)
  else
    print('transparency out of range (' .. transparency .. ')')
  end
end

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
g.neovide_transparency = transparency

vim.keymap.set('n', '<C-+>', function() change_transparency(0.1) end)
vim.keymap.set('n', '<C-_>', function() change_transparency(-0.1) end)
