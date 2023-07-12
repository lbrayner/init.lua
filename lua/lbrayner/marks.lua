local M = {}

local current_mark

local function mark_navigator()
  local global_marks = vim.fn.getmarklist()

  local file_marks = vim.tbl_filter(function(mark)
    return mark.mark:match("'".."%u") -- Uppercase letters
  end, global_marks)

  if vim.tbl_isempty(file_marks) then return end

  local file_by_mark = {}
  for _, file_mark in ipairs(file_marks) do
    file_by_mark[file_mark.mark] = file_mark.file
  end

  local indexed_marks = {}
  for _, file_mark in ipairs(file_marks) do
    table.insert(indexed_marks, 1, file_mark.mark)
  end
  vim.tbl_add_reverse_lookup(indexed_marks)

  return file_by_mark, indexed_marks
end

local function file_mark_next_file()
  local idx
  local file_by_mark, indexed_marks = mark_navigator()

  if not indexed_marks then return end

  if not current_mark then
    idx = 1
    current_mark = indexed_marks[idx]
  else
    idx = indexed_marks[current_mark]
  end

  if idx == #indexed_marks then
    current_mark = indexed_marks[1]
  else
    current_mark = indexed_marks[idx+1]
  end

  return file_by_mark[current_mark]
end

function M.go_to_next_file_mark()
  local next_file = file_mark_next_file()
  if not next_file then return end
  -- Full path because tilde is not expanded in lua
  next_file = vim.fn.fnamemodify(next_file, ":p")
  -- TODO consider buffer position (pos)
  require("lbrayner").jump_to_location(next_file)
end

return M
