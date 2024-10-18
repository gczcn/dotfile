local wezterm = require('wezterm')
local config = {}
local colors = {}

-- Fonts
-- Test: English: Hello
--       中文：   你好
config.font = wezterm.font_with_fallback({
  -- 'Terminus (TTF)',
  -- 'Terminess Nerd Font Mono',
  'JetBrainsMonoMod Nerd Font Mono',
})

-- Jetbrains Mono Bold
config.font_rules = {
  {
    intensity = 'Bold',
    italic = false,
    font = wezterm.font('JetBrainsMonoMod Nerd Font Mono', { weight = 'Bold', stretch = 'Normal', style = 'Normal' })
  },
  {
    intensity = 'Bold',
    italic = true,
    font = wezterm.font('JetBrainsMonoMod Nerd Font Mono', { weight = 'Bold', stretch = 'Normal', style = 'Italic' })
  },
}

config.font_size = 13.5

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 10000

config.max_fps = 120

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
