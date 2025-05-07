local M = {}

M.is_test_file = (function()
  local success, site = pcall(require, "lbrayner.site.lsp")

  if success then
    return function(filename)
      return site.is_test_file(filename)
    end
  end

  return nil
end)()

return M
