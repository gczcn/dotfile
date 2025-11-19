-- ===========================
-- "Features" Configurations
-- ===========================

-- Antonym
require('features.antonym').setup()
vim.keymap.set('n', '<leader>ta', '<cmd>AntonymWord<CR>')
