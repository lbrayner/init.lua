-- From vim-ripgrep (https://github.com/lbrayner/vim-ripgrep)

local M = {}

local function rg(txt, loclist)
  local command = "grep"
  if loclist then
    command = "lgrep"
  end
  local rgopts = " "
  if vim.go.ignorecase then
    rgopts = rgopts.."-i "
  end
  if vim.go.smartcase then
    rgopts = rgopts.."-S "
  end
  if not vim.startswith(vim.go.grepprg, "rg") then
    error("Rg: 'grepprg' not correctly set.")
  end
  if not vim.fn.executable("rg") then
    error("Rg: 'rg' not executable.")
  end
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

  if txt == "" then
    -- https://neovim.discourse.group/t/function-that-return-visually-selected-text/1601
    local pos_start = vim.api.nvim_buf_get_mark(0, "<")
    local pos_end = vim.api.nvim_buf_get_mark(0, ">")
    if command.line1 ~= pos_start[1] or
      command.line2 ~= pos_end[1] then
      vim.cmd.echomsg("'Line range not allowed, only visual selection.'")
      return
    end
    if pos_start[1] ~= pos_end[1] then
      vim.cmd.echomsg("'Visual selection pattern cannot span multiple lines.'")
      return
    end
    txt = vim.api.nvim_buf_get_text(0, pos_start[1] - 1, pos_start[2], pos_end[1] - 1, pos_end[2] + 1, {})[1]
  end

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
end, { complete = "file", nargs = "*", range = true })

vim.keymap.set("ca", "Rg", "Rg -e")
vim.keymap.set("ca", "Rb", [[Rg -s -e'\b''''\b'<Left><Left><Left><Left><Left>]])
vim.keymap.set("ca", "Rw", [[Rg -s -e'\b''<C-R><C-W>''\b']])

return M
