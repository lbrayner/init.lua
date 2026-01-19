local concat = table.concat
local getbufinfo = vim.fn.getbufinfo

local M = {}

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
