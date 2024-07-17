-- |default|simple|clean|
vim.g.setup_mode = 'default'

-- true: enabled game plugins
-- 'just_default': Only enabled game plugins in default mode
-- false: desabled game plugins
vim.g.enabled_game_plugins = 'just_default'
require('mode').setup(vim.g.setup_mode)
