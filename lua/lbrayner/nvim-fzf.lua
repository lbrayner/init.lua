local concat = table.concat

local function run_module(name)
  return function(...)
    require(name)(...)
  end
end

local M = {}

M.buffers = run_module("lbrayner.nvim-fzf.commands.buffers")
M.files = run_module("lbrayner.nvim-fzf.commands.files")
M.marks = run_module("lbrayner.nvim-fzf.commands.marks")
M.tabs = run_module("lbrayner.nvim-fzf.commands.tabs")

M.setup = run_module("lbrayner.nvim-fzf.setup")

return M
