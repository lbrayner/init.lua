local M = {}

local current_mark

function M.file_mark_navigator()
  local global_marks = vim.fn.getmarklist()

  local file_marks = vim.tbl_filter(function(mark)
    return mark.mark:match("'".."%u") -- Uppercase letters
  end, global_marks)

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
  local pos = { mark.pos[2], (mark.pos[3] - 1) }
  -- Full path because tilde is not expanded in lua
  filename = vim.fn.fnamemodify(filename, ":p")
  require("lbrayner").jump_to_location(filename, pos)
end

function M.go_to_previous_file_mark()
  local previous_mark = file_mark_previous_mark()
  go_to_file_mark(previous_mark)
end

function M.go_to_next_file_mark()
  local next_mark = file_mark_next_mark()
  go_to_file_mark(next_mark)
end

return M
