local concat = table.concat

local function run_module(name)
  return function(...)
    require(name)(...)
  end
end

local M = {}

M.files = run_module("lbrayner.nvim-fzf.commands.files")
M.marks = run_module("lbrayner.nvim-fzf.commands.marks")
M.setup = run_module("lbrayner.nvim-fzf.setup")

function M.get_history_file(suffix)
  assert(not suffix or type(suffix) == "string", "'suffix' must be a string")

  local history_file

  if vim.go.shadafile == "" then
    history_file = "fzf_history_main"
  else
    local fnamemodify = vim.fn.fnamemodify
    local shadafile = fnamemodify(fnamemodify(vim.go.shadafile, ":r"), ":t")

    history_file = concat({ "fzf_history_", shadafile })
  end

  if suffix then
    history_file = concat({ history_file, "_", suffix })
  end

  return vim.fs.joinpath(vim.fn.stdpath("cache"), history_file)
end

return M
