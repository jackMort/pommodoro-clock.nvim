local Popup = require("nui.popup")

local Utils = require("pommodoro-clock.utils")

local M = {}

M.setup = function()
  vim.api.nvim_set_hl(0, "PommodoroClockG1", { fg = "#ccff33" })
  vim.api.nvim_set_hl(0, "PommodoroClockG2", { fg = "#9ef01a" })
  vim.api.nvim_set_hl(0, "PommodoroClockG3", { fg = "#70e000" })
  vim.api.nvim_set_hl(0, "PommodoroClockMin", { fg = "#666666" })
  vim.api.nvim_set_hl(0, "PommodoroClockText", { fg = "#ff3399" })

  M.namespace_id = vim.api.nvim_create_namespace("PommodoroClock")
end

M.modes = {
  ["work"] = { "POMMODORO", 25 },
  ["short_break"] = { "SHORT BREAK", 5 },
  ["long_break"] = { "LONG BREAK", 30 },
}

M.current_state = {
  mode = M.modes["work"],
  time = nil,
  popup = nil,
}

--[[
  Start a short break.
]]
M.start_short_break = function()
  M.current_state.mode = M.modes["short_break"]
  M.start_timer()
end

--[[
  Start a long break.
]]
M.start_long_break = function()
  M.current_state.mode = M.modes["long_break"]
  M.start_timer()
end

--[[
  Start a work session.
]]
M.start_work = function()
  M.current_state.mode = M.modes["work"]
  M.start_timer()
end

M.toggle_pause = function()
  if M.current_state.timer == nil then
    return
  end
  if M.current_state.paused then
    M.current_state.paused = false
    M.current_state.timer:start(0, 1000, vim.schedule_wrap(M.tick))
  else
    M.current_state.paused = true
    M.current_state.timer:stop()
  end
end

M.close = function()
  if M.current_state.timer then
    M.current_state.timer:stop()
  end

  if M.current_state.popup then
    M.current_state.popup:unmount()
    M.current_state.popup = nil
  end

  M.say("See you later")
end

M.start_timer = function()
  if M.current_state.timer ~= nil then
    M.current_state.timer:stop()
  end

  local mode = M.current_state.mode[1]
  local mode_time = M.current_state.mode[2]

  M.show_popup()
  M.say_event(mode, "start")

  M.current_state.time = mode_time * 60
  M.current_state.timer = vim.loop.new_timer()

  M.current_state.timer:start(0, 1000, vim.schedule_wrap(M.tick))
end

M.tick = function()
  if M.current_state.time == 0 then
    M.current_state.timer:stop()
    M.say_event(M.current_state.mode[1], "end")
  end

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

  M.current_state.time = M.current_state.time - 1
end

--
-- private methods
--

M.show_popup = function()
  if M.current_state.popup == nil then
    M.current_state.popup = Popup({
      position = { row = 0, col = "100%" },
      size = {
        width = 38,
        height = 5,
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
        winblend = 0,
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      },
    })
    M.current_state.popup:mount()
  end
end

M.say_event = function(mode, type)
  M.say(mode .. " session " .. type)
end

M.say = function(text)
  os.execute('spd-say -l en -t female3 "' .. text .. '"')
end

return M
