local M = {}

local function run_module(name)
  return function(...)
    require(name)(...)
  end
end

M.files = run_module("lbrayner.nvim-fzf.files")

return M
