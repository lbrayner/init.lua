-- From vim-ripgrep (https://github.com/lbrayner/vim-ripgrep)

local M = {}

local function rg(txt, loclist)
  local command = "grep!"
  if loclist then
    command = "lgrep!"
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
  vim.cmd("silent "..command.." "..rgopts..vim.fn.escape(txt, "#%|"))
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

local function ripgrep(txt, line1, line2)
  if txt == "" then
    -- https://neovim.discourse.group/t/function-that-return-visually-selected-text/1601
    local pos_start = vim.api.nvim_buf_get_mark(0, "<")
    local pos_end = vim.api.nvim_buf_get_mark(0, ">")
    if line1 ~= pos_start[1] or
      line2 ~= pos_end[1] then
      print("Line range not allowed, only visual selection.")
      return
    end
    if pos_start[1] ~= pos_end[1] then
      print("Visual selection pattern cannot span multiple lines.")
      return
    end
    txt = vim.api.nvim_buf_get_text(0, pos_start[1] - 1, pos_start[2], pos_end[1] - 1, pos_end[2] + 1, {})[1]
    txt = string.format("-s -F -e %s", vim.fn.shellescape(txt))
  end

  local success, err = pcall(M.rg, txt)

  if not success then
    vim.cmd.cclose()
    if type(err) == "string" and string.find(err, " Rg:") then
      error(err)
    end
    print(string.format("Error searching for “%s”. Unmatched quotes? Check your command.", txt))
    return
  end

  vim.fn.setqflist({}, "a", { context = { ripgrep = { txt = txt } } })

  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("botright copen")
  else
    vim.cmd.cclose()
    print(string.format("No match found for “%s”.", txt))
  end
end

vim.api.nvim_create_user_command("Rg", function(command)
  ripgrep(command.args, command.line1, command.line2)
end, { complete = "file", nargs = "*", range = true })

vim.api.nvim_create_user_command("RgAgain", function()
  local context = vim.fn.getqflist({ context = 1 }).context
  if vim.tbl_get(context, "ripgrep", "txt") then
    ripgrep(context.ripgrep.txt)
  else
    print("Cannot perform a ripgrep search without context.")
  end
end, { nargs = 0 })

vim.keymap.set("ca", "Rg", "Rg -e")
vim.keymap.set("ca", "Rb", [[Rg -s -e'\b''''\b'<Left><Left><Left><Left><Left>]])
vim.keymap.set("ca", "Rw", [[Rg -s -e'\b''<C-R><C-W>''\b']])

return M
