local function run_module(name)
  return function(...)
    require(name)(...)
  end
end

local M = {}

M.files = run_module("lbrayner.nvim-fzf.commands.files")
M.marks = run_module("lbrayner.nvim-fzf.commands.marks")
M.tabs = run_module("lbrayner.nvim-fzf.commands.tabs")

M.setup = run_module("lbrayner.nvim-fzf.setup")

-- From fzf-lua.utils
local ansi_escseq = {
  -- the "\x1b" esc sequence causes issues
  -- with older Lua versions
  -- clear    = "\x1b[0m",
  clear     = "[0m",
  bold      = "[1m",
  italic    = "[3m",
  underline = "[4m",
  black     = "[0;30m",
  red       = "[0;31m",
  green     = "[0;32m",
  yellow    = "[0;33m",
  blue      = "[0;34m",
  magenta   = "[0;35m",
  cyan      = "[0;36m",
  white     = "[0;37m",
  grey      = "[0;90m",
  dark_grey = "[0;97m",
}

M.ansi_escseq = require("lbrayner").get_proxy_table(ansi_escseq)

return M
