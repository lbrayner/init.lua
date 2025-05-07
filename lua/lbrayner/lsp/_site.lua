local M = {}

function M.is_test_file(filename)
  local success, site = pcall(require, "lbrayner.site.lsp")

  if success then
    return site.is_test_file(filename)
  end
end

return M
