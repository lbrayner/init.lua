-- From vim-ripgrep (https://github.com/lbrayner/vim-ripgrep)

local M = {}

local function rg_opts()
  local rgopts = " "
  if vim.go.ignorecase then
    rgopts = rgopts.."-i "
  end
  if vim.go.smartcase then
    rgopts = rgopts.."-S "
  end
  return rgopts
end

local function rg_ready()
  if not vim.startswith(vim.go.grepprg, "rg") then
    error("Rg: 'grepprg' not correctly set.")
  end
  if not vim.fn.executable("rg") then
    error("Rg: 'rg' not executable.")
  end
end

local function rg(txt, locallist)
  local command = "grep"
  if locallist then
    command = "lgrep"
  end
  local rgopts = rg_opts()
  rg_ready()
  -- Escaping Command-line special characters '#', '%' (:h :_%), and '|' (:h :bar)
  vim.cmd("silent "..command.."! "..rgopts..vim.fn.escape(txt, "#%|"))
end

function M.lrg(txt)
  rg(txt, true)
end

function M.rg(txt)
  rg(txt)
end

return M
