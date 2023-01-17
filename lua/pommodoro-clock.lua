local Popup = require("nui.popup")

local Animation = require("pommodoro-clock.animation")
local Utils = require("pommodoro-clock.utils")

local M = {}

---
-- @table config
--
-- @field number animation_duration
-- @field number animation_fps
M.config = {
  animation_duration = 300,
  animation_fps = 30,
  width = 38,
  height = 4,
}

--- Sets up the highlight groups for the pommodoro clock.
--
-- @return nil
M.setup = function()
  vim.api.nvim_set_hl(0, "PommodoroClockG1", { fg = "#ccff33" })
  vim.api.nvim_set_hl(0, "PommodoroClockG2", { fg = "#9ef01a" })
  vim.api.nvim_set_hl(0, "PommodoroClockG3", { fg = "#70e000" })
  vim.api.nvim_set_hl(0, "PommodoroClockMin", { fg = "#666666" })
  vim.api.nvim_set_hl(0, "PommodoroClockText", { fg = "#ff3399" })

  M.namespace_id = vim.api.nvim_create_namespace("PommodoroClock")
end

---
-- A table of modes that can be used to set the timer.
--
-- @table modes
-- @field work A table containing the name and duration of a work mode.
-- @field short_break A table containing the name and duration of a short break mode.
-- @field long_break A table containing the name and duration of a long break mode.
M.modes = {
  ["work"] = { "POMMODORO", 25 },
  ["short_break"] = { "SHORT BREAK", 5 },
  ["long_break"] = { "LONG BREAK", 30 },
}

--- Sets the current state of the application.
--
-- @param mode The mode of the application.
-- @param time The time of the application.
-- @param popup The popup of the application.
M.current_state = {
  mode = M.modes["work"],
  time = nil,
  popup = nil,
}

--- Starts a short break.
--
-- @return nil
M.start_short_break = function()
  M.current_state.mode = M.modes["short_break"]
  M.start_timer()
end

--- Starts a long break.
--
-- @return nil
M.start_long_break = function()
  M.current_state.mode = M.modes["long_break"]
  M.start_timer()
end

--- Starts a work session.
--
-- @return nil
M.start_work = function()
  M.current_state.mode = M.modes["work"]
  M.start_timer()
end

--- Toggles the pause state of the current timer.
--
-- @return nil
M.toggle_pause = function()
  if M.current_state.timer == nil then
    return
  end

  if M.current_state.paused then
    M.current_state.paused = false
    M.current_state.timer:start(0, 1000, vim.schedule_wrap(M.tick))
    M.say_event("unpaused")
  else
    M.current_state.paused = true
    M.current_state.timer:stop()
    M.say_event("paused")
  end

  M.render()
end

--- Closes the current popup and stops the timer
--
-- @return nil
M.close = function()
  if M.current_state.timer then
    M.current_state.timer:stop()
  end

  if M.current_state.popup then
    local animation = Animation:initialize(M.config.animation_duration, M.config.animation_fps, function(fraction)
      M.current_state.popup:update_layout({
        size = {
          width = M.config.width + 1 - math.floor(M.config.width * fraction),
          height = M.config.height,
        },
      })
    end, function()
      M.current_state.popup:unmount()
      M.current_state.popup = nil
    end)
    animation:run()
  end

  M.say("See you later")
end

--- Starts the timer.
--
-- If the timer is already running, it will be stopped.
--
-- @return nil
M.start_timer = function()
  M.current_state.paused = false

  if M.current_state.timer ~= nil then
    M.current_state.timer:stop()
  end

  M.show_popup()
  M.current_state.time = M.current_state.mode[2] * 60

  M.render()
  M.say_event("start")

  M.current_state.timer = vim.loop.new_timer()
  M.current_state.timer:start(0, 1000, vim.schedule_wrap(M.tick))
end

---
-- @function tick
-- @desc This function is called every second by the timer. It updates the
--       popup buffer with the current time remaining.
--
-- @return none
M.tick = function()
  if M.current_state.time == 0 then
    M.current_state.timer:stop()
    M.say_event("end")
  end

  M.render()

  M.current_state.time = M.current_state.time - 1
end

--- Renders the current state of the pomodoro clock.
--
-- @return nil
M.render = function()
  local lines = {}

  local hours = math.floor(M.current_state.time / 3600)
  local minutes = math.floor((M.current_state.time % 3600) / 60)
  local remainingSeconds = M.current_state.time % 60
  local timeString = string.format("c%02d:%02d:%02d", hours, minutes, remainingSeconds)
  for i = 1, #timeString do
    table.insert(lines, string.sub(timeString, i, i))
  end

  lines = Utils.str_to_ascii(lines)
  table.insert(lines, 1, "")
  vim.api.nvim_buf_set_lines(M.current_state.popup.bufnr, 0, 4, false, lines)
  vim.api.nvim_buf_add_highlight(M.current_state.popup.bufnr, M.namespace_id, "PommodoroClockG1", 1, 0, -1)
  vim.api.nvim_buf_add_highlight(M.current_state.popup.bufnr, M.namespace_id, "PommodoroClockG2", 2, 0, -1)
  vim.api.nvim_buf_add_highlight(M.current_state.popup.bufnr, M.namespace_id, "PommodoroClockG3", 3, 0, -1)

  if M.current_state.extmark_id then
    vim.api.nvim_buf_del_extmark(M.current_state.popup.bufnr, M.namespace_id, M.current_state.extmark_id)
  end

  local paused_text = M.current_state.paused and "           PAUSED" or ""

  M.current_state.extmark_id = vim.api.nvim_buf_set_extmark(M.current_state.popup.bufnr, M.namespace_id, 0, 0, {
    virt_text = {
      { "░░ ", "PommodoroClockG1" },
      { M.current_state.mode[1] .. " ", "PommodoroClockText" },
      { M.current_state.mode[2] .. "MIN", "PommodoroClockMin" },
      { paused_text, "PommodoroClockText" },
    },
    virt_text_pos = "overlay",
  })
end

--
-- private methods
--

M.show_popup = function()
  if M.current_state.popup == nil then
    M.current_state.popup = Popup({
      position = { row = 0, col = "100%" },
      size = {
        width = 1,
        height = M.config.height,
      },
      focusable = false,
      relative = "win",
      border = {
        style = "none",
      },
      buf_options = {
        modifiable = true,
        readonly = false,
      },
      win_options = {
        winblend = 30,
        winhighlight = "Normal:,FloatBorder:",
      },
    })

    M.current_state.popup:mount()
    local animation = Animation:initialize(M.config.animation_duration, M.config.animation_fps, function(fraction)
      M.current_state.popup:update_layout({
        size = {
          width = math.floor(M.config.width * fraction),
          height = M.config.height,
        },
      })
    end)
    animation:run()
  end
end

M.say_event = function(type)
  M.say(M.current_state.mode[1] .. " session " .. type)
end

M.say = function(text)
  os.execute('spd-say -l en -t female3 "' .. text .. '"')
end

return M