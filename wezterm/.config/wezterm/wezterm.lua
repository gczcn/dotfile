local wezterm = require('wezterm')
local config = {}
local colors = {}

-- Fonts
-- Test: English: Hello
--       中文：   你好
config.font = wezterm.font_with_fallback({
  'NotoSansM Nerd Font Mono',
  -- 'GoMono Nerd Font Mono',
  -- { family = 'Noto Serif SC', weight = 'Medium' },
  -- 'BlexMono Nerd Font Mono',
  -- 'Sarasa Term SC',
  -- 'Terminus (TTF)',
  -- 'JetBrainsMono Nerd Font Mono',
  -- 'Terminess Nerd Font Mono',
})

config.font_size = 11

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 10000

colors['tab_bar'] = { background = '#3c3836',

  active_tab = {
    bg_color = '#a89984',
    fg_color = '#282828',
    intensity = 'Bold',
  },

  inactive_tab = {
    bg_color = '#504945',
    fg_color = '#ebdbb2'
  },

  inactive_tab_hover = {
    bg_color = '#665c54',
    fg_color = '#ebdbb2',
    intensity = 'Bold',
  },

  new_tab = {
    bg_color = '#8ec07c',
    fg_color = '#282828',
    intensity = 'Bold',
  },

  new_tab_hover = {
    bg_color = '#ebdbb2',
    fg_color = '#282828',
    intensity = 'Bold',
  },
}

-- Window
-- config.window_decorations = 'RESIZE'
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Color Scheme
config.color_scheme = 'GruvboxDark'
config.colors = colors
-- config.color_scheme = 'Catppuccin Mocha'
-- config.color_scheme = 'Tokyo Night'
-- config.color_scheme = 'tokyonight_night'
config.front_end = 'WebGpu'

return config
