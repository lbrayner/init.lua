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
    table.insert(indexed_marks, 1, file_mark.mark)
  end
  vim.tbl_add_reverse_lookup(indexed_marks)

  return file_mark_by_mark, indexed_marks
end

local function file_mark_next_mark()
  local idx
  local file_mark_by_mark, indexed_marks = M.file_mark_navigator()

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

  return file_mark_by_mark[current_mark]
end

function M.go_to_next_file_mark()
  local next_mark = file_mark_next_mark()
  if not next_mark then return end
  local next_file = next_mark.file
  local pos = { next_mark.pos[2], (next_mark.pos[3] - 1) }
  -- Full path because tilde is not expanded in lua
  next_file = vim.fn.fnamemodify(next_file, ":p")
  require("lbrayner").jump_to_location(next_file, pos)
end

return M
