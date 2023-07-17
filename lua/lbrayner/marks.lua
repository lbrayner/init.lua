local M = {}

local current_mark

function M.delete_file_marks()
  vim.cmd("delmarks A-Z")
  current_mark = nil
end

local function get_file_marks()
  local all_marks = vim.fn.getmarklist()

  local file_marks = vim.tbl_filter(function(mark)
    return mark.mark:match("'".."%u") -- Uppercase letters
  end, all_marks)

  return file_marks
end

function M.file_mark_navigator()
  local file_marks = get_file_marks()

  if vim.tbl_isempty(file_marks) then return end

  local file_mark_by_mark = {}
  for _, file_mark in ipairs(file_marks) do
    file_mark_by_mark[file_mark.mark] = file_mark
  end

  local indexed_marks = {}
  for _, file_mark in ipairs(file_marks) do
    table.insert(indexed_marks, file_mark.mark)
  end
  vim.tbl_add_reverse_lookup(indexed_marks)

  return file_mark_by_mark, indexed_marks
end

local function file_mark_previous_mark()
  local idx
  local file_mark_by_mark, indexed_marks = M.file_mark_navigator()

  if not indexed_marks then return end

  if not current_mark then
    idx = #indexed_marks + 1
  else
    idx = indexed_marks[current_mark]
  end

  if idx == 1 then
    current_mark = indexed_marks[#indexed_marks]
  else
    current_mark = indexed_marks[idx-1]
  end

  return file_mark_by_mark[current_mark]
end

local function file_mark_next_mark()
  local idx
  local file_mark_by_mark, indexed_marks = M.file_mark_navigator()

  if not indexed_marks then return end

  if not current_mark then
    idx = 0
  else
    idx = indexed_marks[current_mark]
  end

  if idx == #indexed_marks then
    current_mark = indexed_marks[1]
  else
    current_mark = indexed_marks[idx+1]
  end

  return file_mark_by_mark[current_mark]
end

local function go_to_file_mark(mark)
  if not mark then return end
  local filename = mark.file
  -- Full path because tilde is not expanded in lua
  filename = vim.fn.fnamemodify(filename, ":p")
  local pos
  local bufnr = vim.fn.bufadd(filename)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    pos = { mark.pos[2], (mark.pos[3] - 1) }
  end
  require("lbrayner").jump_to_location(filename, pos)
end

function M.go_to_previous_file_mark()
  -- Try to get a different buffer
  for _ = 1, #get_file_marks() do
    local previous_mark = file_mark_previous_mark()
    if not previous_mark then return end
    local previous_mark_bufnr = previous_mark.pos[1]
    if previous_mark_bufnr ~= vim.api.nvim_get_current_buf() then
      return go_to_file_mark(previous_mark)
    end
  end
end

function M.go_to_next_file_mark()
  -- Try to get a different buffer
  for _ = 1, #get_file_marks() do
    local next_mark = file_mark_next_mark()
    if not next_mark then return end
    local next_mark_bufnr = next_mark.pos[1]
    if next_mark_bufnr ~= vim.api.nvim_get_current_buf() then
      return go_to_file_mark(next_mark)
    end
  end
end

return M
