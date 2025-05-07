local success, site = pcall(require, "lbrayner.site.lsp")

if not success then
  site = nil
end

return setmetatable({}, {
  __index = function(_, key)
    if vim.list_contains(
      {
        "is_test_file",
      }, key) then
      if site and site[key] and type(site[key]) == "function" then
        return site[key]
      else
        return function() end -- noop
      end
    end
  end,
  __newindex = function()
    error("Cannot add item")
  end,
})
