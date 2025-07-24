local M = {}

local contains = require("lbrayner").contains
local join = require("lbrayner").join

function M.loop_buffers(force, predicate)
  local test = function(buf)
    return vim.api.nvim_buf_is_valid(buf.bufnr) and vim.bo[buf.bufnr].buftype ~= "terminal" and predicate(buf)
  end
  local buffer_count = 0
  local error_count = 0
  local ei = vim.o.eventignore
  vim.opt.eventignore:append({ "TabClosed" })
  for _, buf in ipairs(vim.fn.getbufinfo()) do
    if test(buf) then
      local success, _ = pcall(vim.api.nvim_buf_delete, buf.bufnr, { force = force })
      if success then
        buffer_count = buffer_count + 1
      else
        error_count = error_count + 1
      end
    end
  end
  vim.o.eventignore = ei
  return buffer_count, error_count
end

local function wipe_buffers(force, predicate)
  local buffer_count, error_count = M.loop_buffers(force, predicate)
  local message = ""
  if buffer_count == 0 then
    message = "No buffers wiped"
  elseif buffer_count == 1 then
    message = message .. "1 buffer wiped"
  elseif buffer_count > 1 then
    message = message .. buffer_count .. " buffers wiped"
  end
  if error_count == 1 then
    message = message .. "; 1 buffer not wiped"
  elseif error_count > 1 then
    message = message .. "; " .. error_count .. " buffers not wiped"
  end
  vim.cmd.echom(string.format("'%s'", message))
end

---@type table<string, MyCmdSubcommand>
local subcommand_tbl = {}
require("lbrayner.subcommands").create_user_command_and_subcommands("Wipe", subcommand_tbl, {
  bang = true,
  bar = true,
  desc = "Wipe buffers with text, pattern, filetype; not loaded, not readable or hidden",
})

subcommand_tbl.hidden = {
  optional = function(opts)
    local text = join(opts.args)
    wipe_buffers(opts.bang, function(buf)
      return buf.hidden == 1 and contains(buf.name, text)
    end)
  end,
}

subcommand_tbl.notLoaded = {
  simple = function(opts)
    wipe_buffers(opts.bang, function(buf)
      return buf.listed == 1 and buf.loaded == 0
    end)
  end,
}

subcommand_tbl.notReadable = {
  simple = function(opts)
    wipe_buffers(opts.bang, function(buf)
      return buf.listed == 1 and not vim.uv.fs_stat(buf.name)
    end)
  end,
}

subcommand_tbl.pattern = {
  optional = function(opts)
    local pattern = join(opts.args)
    wipe_buffers(opts.bang, function(buf)
      return buf.listed == 1 and string.find(buf.name, pattern)
    end)
  end,
}

subcommand_tbl.text = {
  optional = function(opts)
    local text = join(opts.args)
    wipe_buffers(opts.bang, function(buf)
      return buf.listed == 1 and contains(buf.name, text)
    end)
  end,
}

subcommand_tbl.unlisted = {
  optional = function(opts)
    local text = join(opts.args)
    wipe_buffers(opts.bang, function(buf)
      return buf.listed == 0 and contains(buf.name, text)
    end)
  end,
}

return M
