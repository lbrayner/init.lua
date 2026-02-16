local abspath = vim.fs.abspath
local normalize = vim.fs.normalize
local split = vim.split
local startswith = vim.startswith

local M = {}

-- NVIM v0.12.0-dev-1935+g0f9aae20ec
-- From $VIMRUNTIME/lua/vim/fs.lua
--- @param base string
--- @param target string
--- @param opts table? Reserved for future use
--- @return string|nil
function M.relpath(base, target, opts)
  -- From ChatGPT
  local function down_rel(base, target, level)
    level = type(level) == "number" and level or nil

    local t = split(target, "/", { plain = true })
    local b = split(base, "/", { plain = true })

    -- find common prefix
    local i = 1
    while i <= #t and i <= #b and t[i] == b[i] do
      i = i + 1
    end

    local rel = {}

    -- go up for remaining base parts
    for _ = i, #b do
      table.insert(rel, "..")
    end

    if level and level < #rel then return nil end

    -- go down into target
    for j = i, #t do
      table.insert(rel, t[j])
    end

    if #rel == 0 then
      return "."
    end

    return table.concat(rel, "/")
  end

  opts = opts or {}
  base = normalize(abspath(base))
  target = normalize(abspath(target))
  if base == target then
    return '.'
  end

  local sbase = base .. (base ~= '/' and '/' or '')

  local up = startswith(target, sbase) and target:sub(#sbase + 1) or nil

  if up then return up end

  if not opts.downward then return up end

  local down = down_rel(base, target, opts.downward)

  return nil, down
end

return M
