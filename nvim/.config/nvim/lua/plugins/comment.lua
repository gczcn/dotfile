return {
  'numToStr/Comment.nvim',
  enabled = true,
  keys = {
    { 'gc', mode = { 'n', 'v' } },
    { 'gb', mode = { 'n', 'v' } },

    -- normal mode
    { 'gcc', mode = 'n' },
    { 'gbc', mode = 'n' },
    { 'gco', mode = 'n' },
    { 'gcO', mode = 'n' },
    { 'gcA', mode = 'n' },
  },
  config = function() require('Comment').setup() end,
}
