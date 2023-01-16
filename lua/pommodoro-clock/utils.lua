local M = {}

local zero = [[
█▀▀█
█  █
█▄▄█
]]

local one = [[
▄█░
░█░
▄█▄
]]

local two = [[
█▀█
░▄▀
█▄▄
]]

local tree = [[
█▀▀█
░░▀▄
█▄▄█
]]

local four = [[
░█▀█░
█▄▄█▄
░░░█░
]]

local five = [[
█▀▀
▀▀▄
▄▄▀
]]

local six = [[
▄▀▀▄
█▄▄░
▀▄▄▀
]]

local seven = [[
▀▀▀█
░░█░
░▐▌░
]]

local eight = [[
▄▀▀▄
▄▀▀▄
▀▄▄▀
]]

local nine = [[
▄▀▀▄
▀▄▄█
░▄▄▀
]]

local separator = [[
▄
░
▀
]]

local clock = [[
██
  
  
]]

local chars = {
  ["0"] = zero,
  ["1"] = one,
  ["2"] = two,
  ["3"] = tree,
  ["4"] = four,
  ["5"] = five,
  ["6"] = six,
  ["7"] = seven,
  ["8"] = eight,
  ["9"] = nine,
  [":"] = separator,
  ["c"] = clock,
}

M.split_string_by_line = function(text)
  local lines = {}
  for line in text:gmatch("([^\n]*)\n?") do
    table.insert(lines, line)
  end
  return lines
end

M.str_to_ascii = function(str)
  local lines = {
    {},
    {},
    {},
    {},
  }
  for _, s in ipairs(str) do
    local char = chars[s]
    local char_lines = M.split_string_by_line(char)
    for i, line in ipairs(char_lines) do
      table.insert(lines[i], line)
    end
  end

  return {
    table.concat(lines[1], " "),
    table.concat(lines[2], " "),
    table.concat(lines[3], " "),
  }
end

return M
