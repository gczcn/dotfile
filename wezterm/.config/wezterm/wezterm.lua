local wezterm = require('wezterm')
local config = {}

-- Fonts
-- Test: English: Hello
--       中文：   你好
config.font = wezterm.font_with_fallback({
  'SauceCodePro Nerd Font Mono',
  'Noto Sans SC',
})

-- config.harfbuzz_features = { 'ss01' }  -- JetBrains Mono
-- config.harfbuzz_features = { 'ss06', 'cv10' }  -- Fira Code
-- config.harfbuzz_features = { 'ss04' }  -- Source Code Pro

-- Bold
config.font_rules = {
  {
    intensity = 'Bold',
    italic = false,
    font = wezterm.font_with_fallback({
      { family = 'SauceCodePro Nerd Font Mono', weight = 'Bold', stretch = 'Normal', style = 'Normal' },
      { family = 'Noto Sans SC', weight = 'Bold', stretch = 'Normal', style = 'Normal' },
    }),
  },
  {
    intensity = 'Bold',
    italic = true,
    font = wezterm.font_with_fallback({
      { family = 'SauceCodePro Nerd Font Mono', weight = 'Bold', stretch = 'Normal', style = 'Normal' },
      { family = 'Noto Sans SC', weight = 'Bold', stretch = 'Normal', style = 'Normal' },
    }),
  },
}

-- config.font_size = 13.3
-- config.font_size = 14.4
-- config.font_size = 11
config.font_size = 14

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 10000

config.max_fps = 120
config.animation_fps = 120

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
config.colors = require('colorscheme.gruvbox_dark_medium')
-- config.colors = require('colorscheme.everforest-dark-hard')
-- config.color_scheme = 'Everforest Dark (Hard)'
-- config.color_scheme = 'Catppuccin Mocha'
-- config.color_scheme = 'Tokyo Night'
-- config.color_scheme = 'tokyonight_night'
config.front_end = 'WebGpu'

return config
