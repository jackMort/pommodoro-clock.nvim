local pc = require("pommodoro-clock")
vim.api.nvim_create_user_command("PommodoroClock", function()
  pc.start_timer()
end, {})

vim.api.nvim_create_user_command("PommodoroClockShortBreak", function()
  pc.start_short_break()
end, {})
