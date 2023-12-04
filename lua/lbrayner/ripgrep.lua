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

vim.go.grepprg = "rg --vimgrep"
vim.go.grepformat = "%f:%l:%c:%m"
vim.go.shellpipe = "&>"

vim.api.nvim_create_user_command("Rg", function(command)
  local txt = command.args
  local success, err = pcall(M.rg, txt)

  if not success then
    vim.cmd.cclose()
    if type(err) == "string" and string.find(err, " Rg:") then
      vim.cmd.echoerr(string.format('"%s"', vim.fn.escape(err, '"')))
      return
    end
    vim.cmd.echomsg(string.format('"Error searching for %s. Unmatched quotes? Check your command."',
      vim.fn.escape(txt, '"')))
    return
  end

  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("botright copen")
  else
    vim.cmd.cclose()
    vim.cmd.echomsg(string.format('"No match found for “%s”."', vim.fn.escape(txt, [["\]])))
  end
end, { complete = "file", nargs = "*" })

vim.keymap.set("ca", "Rg", "Rg -e")
vim.keymap.set("ca", "Rb", [[Rg -s -e'\b''''\b'<Left><Left><Left><Left><Left>]])
vim.keymap.set("ca", "Rw", [[Rg -s -e'\b''<C-R><C-W>''\b']])

return M
