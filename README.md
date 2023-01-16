# pommodoro-clock.nvim

![GitHub Workflow Status](http://img.shields.io/github/actions/workflow/status/jackMort/pommodoro-clock.nvim/default.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)


`Pommodoro-Clock` is a plugin that displays an ASCII timer in an overlay. It helps users stay focused and productive by using the Pomodoro Technique.
Users can set a timer, view a countdown, and pause/resume the timer.

![preview image](https://github.com/jackMort/pommodoro-clock.nvim/blob/media/preview.png?raw=true)

## Installation

```lua
-- Packer
use({
  "jackMort/pommodoro-clock.nvim",
    config = function()
      require("chatgpt").setup({
        -- optional configuration
      })
    end,
    requires = {
      "MunifTanjim/nui.nvim",
    }
})
```

## Usage

Plugin exposes the following public functions, here is a sample of the keybindings.

```lua
local function pc(func)
  return "<Cmd>lua require('pommodoro-clock')." .. func .. "()<CR>"
end

lvim.builtin.which_key.mappings["k"] = {
  w = { pc("start_work"), "Start Pommodoro" },
  s = { pc("start_short_break"), "Short Break" },
  l = { pc("start_long_break"), "Long Break" },
  c = { pc("toggle_pause"), "Toggle Pause" },
  c = { pc("close"), "Close" },
}
```

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/jackMort)
