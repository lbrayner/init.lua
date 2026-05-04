local concat = table.concat
local getbufinfo = vim.fn.getbufinfo
local jobwait = vim.fn.jobwait

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

function M.coroutine_wrap(f)
  return coroutine.wrap(function()
    f()

    if vim.bo.buftype == "terminal" then
      vim.cmd.stopinsert()
    end
  end)
end

-- From fzf-lua.providers.buffers's gen_buffer_entry
function M.get_buffer_infos()
  local curbuf = vim.api.nvim_get_current_buf()
  local altbuf = vim.fn.bufnr("#")
  local infos = {}

  for _, info in ipairs(getbufinfo()) do
    local bufnr = info.bufnr
    local listed = info.listed == 1 and " " or "u"
    local current = bufnr == curbuf and "%" or bufnr == altbuf and "#" or " "
    local active = info.hidden == 1 and "h" or info.loaded == 1 and "a" or " "
    local readonly = (
      vim.bo[bufnr].readonly and "=" or vim.bo[bufnr].modifiable and " " or "-"
    )
    local modified = vim.bo[bufnr].modified == 1 and "+" or " "
    local terminal = jobwait({ vim.bo[bufnr].channel }, 0)[1] < -2 and "R" or "F"
    info.flags = concat({
      listed, current, active,
      vim.bo[bufnr].buftype == "terminal" and terminal or readonly,
      modified
    })

    infos[bufnr] = info
  end

  return infos
end

return M
