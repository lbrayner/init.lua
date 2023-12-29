local M = {}

local current_mark

function M.delete_file_marks()
  vim.cmd("delmarks A-Z")
  current_mark = nil
end

local function get_file_mark_info_list()
  local file_mark_info_list = vim.tbl_filter(function(mark)
    return mark.mark:match("^'%u$") -- Uppercase letters
  end, vim.fn.getmarklist())

  return file_mark_info_list
end

function M.file_mark_navigator()
  local file_mark_info_list = get_file_mark_info_list()

  if vim.tbl_isempty(file_mark_info_list) then return end

  local file_mark_info_by_mark = {}
  for _, file_mark_info in ipairs(file_mark_info_list) do
    file_mark_info_by_mark[file_mark_info.mark] = file_mark_info
  end

  local indexed_marks = {}
  for _, file_mark_info in ipairs(file_mark_info_list) do
    table.insert(indexed_marks, file_mark_info.mark)
  end
  vim.tbl_add_reverse_lookup(indexed_marks)

  return file_mark_info_by_mark, indexed_marks
end

local function file_mark_previous()
  local idx
  local file_mark_info_by_mark, indexed_marks = M.file_mark_navigator()

  if not indexed_marks then return end

  if not current_mark or not indexed_marks[current_mark] then
    idx = #indexed_marks + 1
  else
    idx = indexed_marks[current_mark]
  end

  local previous_mark
  if idx == 1 then
    previous_mark = indexed_marks[#indexed_marks]
  else
    previous_mark = indexed_marks[idx-1]
  end

  return file_mark_info_by_mark[previous_mark]
end

local function file_mark_next()
  local idx
  local file_mark_info_by_mark, indexed_marks = M.file_mark_navigator()

  if not indexed_marks then return end

  if not current_mark or not indexed_marks[current_mark] then
    idx = 0
  else
    idx = indexed_marks[current_mark]
  end

  local next_mark
  if idx == #indexed_marks then
    next_mark = indexed_marks[1]
  else
    next_mark = indexed_marks[idx+1]
  end

  return file_mark_info_by_mark[next_mark]
end

function M.get_current_mark()
  return current_mark
end

function M.go_to_file_by_file_mark(mark)
  assert(type(mark) == "string", "Bad argument; 'mark' must be a string.")
  assert(mark:match("^'%u$"), "Bad argument; 'mark' must be a file mark.")
  local file_mark_info_by_mark, _ = M.file_mark_navigator()
  local file_mark_info = file_mark_info_by_mark[mark]
  if not file_mark_info then
    print(string.format("“%s” is not set."))
    return
  end
  M.go_to_file_by_file_mark_info(file_mark_info)
end

function M.go_to_file_by_file_mark_info(file_mark_info)
  print(string.format("Jumped to %s: %s.", file_mark_info.mark, file_mark_info.file))
  if not file_mark_info then return end
  current_mark = file_mark_info.mark
  local file = file_mark_info.file
  -- Normalized path because tilde is not expanded in lua
  file = vim.fs.normalize(file)
  local pos
  local bufnr = vim.fn.bufadd(file)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    pos = { file_mark_info.pos[2], (file_mark_info.pos[3] - 1) }
  end
  require("lbrayner").jump_to_location(file, pos)
end

function M.go_to_previous_file_mark()
  -- Try to get a different buffer
  for _ = 1, #get_file_mark_info_list() do
    local previous_mark = file_mark_previous()
    if not previous_mark then return end
    local previous_mark_bufnr = previous_mark.pos[1]
    if previous_mark_bufnr ~= vim.api.nvim_get_current_buf() then
      return M.go_to_file_by_file_mark_info(previous_mark)
    end
  end
end

function M.go_to_next_file_mark()
  -- Try to get a different buffer
  for _ = 1, #get_file_mark_info_list() do
    local next_mark = file_mark_next()
    if not next_mark then return end
    local next_mark_bufnr = next_mark.pos[1]
    if next_mark_bufnr ~= vim.api.nvim_get_current_buf() then
      return M.go_to_file_by_file_mark_info(next_mark)
    end
  end
end

-- Autocmds

local marks = vim.api.nvim_create_augroup("marks", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = marks,
  desc = "Maybe set current file mark's initial value (file mark navigator)",
  callback = function()
    local tabnr = vim.api.nvim_get_current_tabpage()
    local tabinfo = vim.fn.gettabinfo(tabnr)[1]
    local file_mark_info_by_mark, _ = M.file_mark_navigator()
    for _, win in ipairs(tabinfo.windows) do
      local bufnr = vim.api.nvim_win_get_buf(win)
      for _, file_mark_info in pairs(file_mark_info_by_mark) do
        if vim.fs.normalize(file_mark_info.file) == vim.api.nvim_buf_get_name(bufnr) then
          current_mark = file_mark_info.mark
          return
        end
      end
    end
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = marks })
end

-- Commands
vim.api.nvim_create_user_command("Delfilemarks", M.delete_file_marks, { nargs = 0 })

-- Mappings
vim.keymap.set("n", "]4", M.go_to_next_file_mark)
vim.keymap.set("n", "[4", M.go_to_previous_file_mark)

return M
