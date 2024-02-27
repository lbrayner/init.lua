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

vim.go.grepprg = "rg --vimgrep --sort path"
vim.go.grepformat = "%f:%l:%c:%m"
vim.go.shellpipe = "&>"

vim.api.nvim_create_user_command("Rg", function(command)
  local txt = command.args
  local count = command.count
  local line1 = command.line1
  local line2 = command.line2

  if count == 0 then -- :0Rg
    local context = vim.fn.getqflist({ context = 1 }).context
    if vim.tbl_get(context, "ripgrep", "txt") then
      -- :0Rg performs a search with the last text juxtaposed with the new text
      txt = vim.trim(table.concat({ context.ripgrep.txt, txt }, " "))
    else
      print("Could not find a ripgrep search context.")
      return
    end
  elseif count > 0 then -- :'<,'>Rg
    -- https://neovim.discourse.group/t/function-that-return-visually-selected-text/1601
    local pos_start = vim.api.nvim_buf_get_mark(0, "<")
    local pos_end = vim.api.nvim_buf_get_mark(0, ">")
    if line1 ~= pos_start[1] or line2 ~= pos_end[1] then
      print("Line range not allowed, only visual selection.")
      return
    end
    if pos_start[1] ~= pos_end[1] then
      print("Visual selection pattern cannot span multiple lines.")
      return
    end
    local start_row = pos_start[1] - 1
    local start_col = pos_start[2]
    local end_row = pos_end[1] - 1
    local end_col = pos_end[2] + 1
    local visual_selection = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})[1]
    txt = vim.trim(table.concat({
      string.format("-s -F -e %s", vim.fn.shellescape(visual_selection)),
      txt }, " "))
  end

  local success, err = pcall(M.rg, txt)

  if not success then
    vim.cmd.cclose()
    if type(err) == "string" and require("lbrayner").contains(err, " Rg:") then
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
end, { complete = "file", nargs = "*", range = -1 })

vim.keymap.set("ca", "Rg", "Rg -e")
vim.keymap.set("ca", "Rb", [[Rg -s -e'\b''\b'<Left><Left><Left><Left>]])
vim.keymap.set("ca", "Rw", [[Rg -s -e'\b'<C-R><C-W>'\b']])

return M
