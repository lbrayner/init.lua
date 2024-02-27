local contains = require("lbrayner").contains

local function loop_buffers(force, predicate)
  local test = function(buf)
    return vim.bo[buf.bufnr].buftype ~= "terminal" and predicate(buf)
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
  local buffer_count, error_count = loop_buffers(force, predicate)
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

vim.api.nvim_create_user_command("BWipe", function(command)
  wipe_buffers(command.bang, function(buf)
    return buf.listed == 1 and contains(buf.name, command.args)
  end)
end, { bang = true, complete = "file", nargs = 1 })

vim.api.nvim_create_user_command("BWipeLuaPattern", function(command)
  wipe_buffers(command.bang, function(buf)
    return buf.listed == 1 and string.find(buf.name, command.args)
  end)
end, { bang = true, complete = "file", nargs = 1 })

vim.api.nvim_create_user_command("BWipeFileType", function(command)
  wipe_buffers(command.bang, function(buf)
    local filetype = command.args
    if filetype == "" then
      filetype = vim.bo.filetype -- Current buffer
    end
    return vim.bo[buf.bufnr].filetype == filetype
  end)
end, { bang = true, complete = "filetype", nargs = "?" })

vim.api.nvim_create_user_command("BWipeHidden", function(command)
  wipe_buffers(command.bang, function(buf)
    return buf.hidden == 1 and contains(buf.name, command.args)
  end)
end, { bang = true, complete = "file", nargs = "*" })

vim.api.nvim_create_user_command("BWipeUnlisted", function(command)
  wipe_buffers(command.bang, function(buf)
    return buf.listed == 0 and contains(buf.name, command.args)
  end)
end, { bang = true, complete = "file", nargs = "*" })

vim.api.nvim_create_user_command("BWipeNotLoaded", function(command)
  wipe_buffers(command.bang, function(buf)
    return buf.listed == 1 and buf.loaded == 0
  end)
end, { nargs = 0 })

vim.api.nvim_create_user_command("BWipeNotReadable", function(command)
  wipe_buffers(command.bang, function(buf)
    return buf.listed == 1 and vim.fn.filereadable(buf.name) == 0
  end)
end, { bang = true, nargs = 0 })
