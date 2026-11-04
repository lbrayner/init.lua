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

function M.with_jdtls(fn)
  local bufnr = vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })
  local _, client = next(clients)

  -- From nvim-jdtls
  if not client then
    notify("No LSP client with name `jdtls` available", vim.log.levels.WARN)
    return
  end

  fn(client, bufnr)
end

return M
