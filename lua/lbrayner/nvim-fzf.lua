local M = {}

local function run_module(name)
  return function(...)
    require(name)(...)
  end
end

M.files = run_module("lbrayner.nvim-fzf.commands.files")
M.marks = run_module("lbrayner.nvim-fzf.commands.marks")
M.setup = run_module("lbrayner.nvim-fzf.setup")

return M
