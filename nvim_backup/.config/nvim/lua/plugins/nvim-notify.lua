return {
  {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    config = function()
      local top_down = true
      local stages_util = require("notify.stages.util")
      local direction = top_down and require('notify.stages.util').DIRECTION.TOP_DOWN
      or require('notify.stages.util').DIRECTION.BOTTOM_UP

      ---@diagnostic disable-next-line: missing-fields
      require('notify').setup({
        stages = {
          function(state)
            local next_height = state.message.height + 2
            local next_row = stages_util.available_slot(state.open_windows, next_height, direction)
            if not next_row then
              return nil
            end
            return {
              relative = "editor",
              anchor = "NE",
              width = state.message.width,
              height = state.message.height,
              col = vim.opt.columns:get(),
              row = next_row,
              border = "single",
              style = "minimal",
              opacity = 0,
            }
          end,
          function(state, win)
            return {
              opacity = { 100 },
              col = { vim.opt.columns:get() },
              row = {
                stages_util.slot_after_previous(win, state.open_windows, direction),
                frequency = 3,
                complete = function()
                  return true
                end,
              },
            }
          end,
          function(state, win)
            return {
              col = { vim.opt.columns:get() },
              time = true,
              row = {
                stages_util.slot_after_previous(win, state.open_windows, direction),
                frequency = 3,
                complete = function()
                  return true
                end,
              },
            }
          end,
          function(state, win)
            return {
              width = {
                1,
                frequency = 2.5,
                damping = 0.9,
                complete = function(cur_width)
                  return cur_width < 3
                end,
              },
              opacity = {
                0,
                frequency = 2,
                complete = function(cur_opacity)
                  return cur_opacity <= 4
                end,
              },
              col = { vim.opt.columns:get() },
              row = {
                stages_util.slot_after_previous(win, state.open_windows, direction),
                frequency = 3,
                complete = function()
                  return true
                end,
              },
            }
          end,
        },
        level = 1,
        timeout = 1000,
        fps = 60,
        icons = {
          ERROR = "E:",
          WARN = "W:",
          INFO = "I:",
          DEBUG = "D:",
          TRACE = "T:",
        }
      })
    end,
  }
}
