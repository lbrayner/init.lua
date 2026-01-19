local concat = table.concat
local getbufinfo = vim.fn.getbufinfo

local M = {}

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

-- From fzf-lua.providers.buffers's gen_buffer_entry
function M.get_buffer_info(bufnr)
  local info = getbufinfo(bufnr)[1]
  local hidden = info.hidden == 1 and "h" or "a"
  local readonly = vim.bo[bufnr].readonly and "=" or " "
  local changed = info.changed == 1 and "+" or " "
  info.flags = concat({ hidden, readonly, changed })
  return info
end

return M
