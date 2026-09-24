local M = {}

local concat = table.concat
local find_root = require("jdtls.setup").find_root
local joinpath = vim.fs.joinpath
local readfile = vim.fn.readfile

function M.get_current_project_name()
  local root = find_root({ ".project" })

  if not root then
    return
  end

  local lines = readfile(joinpath(root, ".project"))
  local xml = concat(lines, "\n")

  return xml:match("<name>%s*(.-)%s*</name>")
end

return M
