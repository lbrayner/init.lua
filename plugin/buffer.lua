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
  return { buffer_count = buffer_count, error_count = error_count }
end

local function wipe_buffers(force, predicate)
  local count = loop_buffers(bang, predicate)
  local message = ""
  if count.buffer_count == 0 then
    message = "No buffers wiped"
  elseif count.buffer_count == 1 then
    message = message .. "1 buffer wiped"
  elseif count.buffer_count > 1 then
    message = message .. count.buffer_count .. " buffers wiped"
  end
  if count.error_count == 1 then
    message = message .. "; 1 buffer not wiped"
  elseif count.error_count > 1 then
    message = message .. "; " .. count.error_count .. " buffers not wiped"
  end
  vim.cmd.echom(string.format("'%s'", message))
end

vim.api.nvim_create_user_command("BWipe", function(command)
  wipe_buffers(command.bang, function(buf)
    return buf.listed and string.find(buf.name, command.args)
  end)
end, { bang = true, complete = "file", nargs = 1 })
