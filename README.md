# pommodoro-clock.nvim

![GitHub Workflow Status](http://img.shields.io/github/actions/workflow/status/jackMort/pommodoro-clock.nvim/default.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)


`Pommodoro-Clock` is a plugin that displays an ASCII timer in an overlay. It helps users stay focused and productive by using the Pomodoro Technique.
Users can set a timer, view a countdown, and pause/resume the timer.

![preview image](https://github.com/jackMort/pommodoro-clock.nvim/blob/media/preview.gif?raw=true)

## Installation

```lua
-- Packer
use({
  "jackMort/pommodoro-clock.nvim",
    config = function()
      require("pommodoro-clock").setup({
        -- optional configuration
      })
    end,
    requires = {
      "MunifTanjim/nui.nvim",
    }
})
```

## Configuration

`pommodoro-clock.nvim` comes with the following defaults

```lua
{
  modes = {
    ["work"] = { "POMMODORO", 25 },
    ["short_break"] = { "SHORT BREAK", 5 },
    ["long_break"] = { "LONG BREAK", 30 },
  },
  animation_duration = 300,
  animation_fps = 30,
  say_command = "spd-say -l en -t female3",
  sound = "voice", -- set to "none" to disable
}
```

## Usage

Plugin exposes the following public functions, here is a sample of the keybindings using [which-key](https://github.com/folke/which-key.nvim).

```lua
local function pc(func)
	return "<Cmd>lua require('pommodoro-clock')." .. func .. "<CR>"
end

p = {
	name = "Pommodoro",
	w = { pc('start("work")'), "Start Pommodoro" },
	s = { pc('start("short_break")'), "Short Break" },
	l = { pc('start("long_break")'), "Long Break" },
	p = { pc("toggle_pause()"), "Toggle Pause" },
	c = { pc("close()"), "Close" },
}
```

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/jackMort)
