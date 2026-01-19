local concat = table.concat

local function run_module(name)
  return function(...)
    require(name)(...)
  end
end

local M = {}

M.files = run_module("lbrayner.nvim-fzf.commands.files")
M.marks = run_module("lbrayner.nvim-fzf.commands.marks")
M.tabs = run_module("lbrayner.nvim-fzf.commands.tabs")

M.setup = run_module("lbrayner.nvim-fzf.setup")

local ansi = { clear = concat({ string.char(27), "[0m" }) }

-- From Brave's Leo AI
function ansi.color_to_ansi(color, property)
  local ansiCodes = {
    -- Colors
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,
    -- Properties
    normal = 0,
    bold = 1,
    italic = 3
  }

  local code = ansiCodes[color] or ansiCodes["white"] -- default to white if color not found
  local propCode = ansiCodes[property] or ansiCodes["normal"]

  -- Combine codes: property first, then color
  return concat({ string.char(27), "[", propCode, ";", code, "m" })
end

M.ansi = ansi

return M
