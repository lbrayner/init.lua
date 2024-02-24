local M = {}

local current_mark

local function get_file_mark_info_list()
  local file_mark_info_list = vim.tbl_filter(function(mark)
    return mark.mark:match("^'%u$") -- Uppercase letters
  end, vim.fn.getmarklist())

  return file_mark_info_list
end

local function get_file_mark_navigator()
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

local function file_mark_info_get_previous(mark)
  local idx
  local file_mark_info_by_mark, indexed_marks = get_file_mark_navigator()

  if not indexed_marks then return end

  if not mark or not indexed_marks[mark] then
    idx = #indexed_marks + 1
  else
    idx = indexed_marks[mark]
  end

  local previous_mark
  if idx == 1 then
    previous_mark = indexed_marks[#indexed_marks]
  else
    previous_mark = indexed_marks[idx-1]
  end

  return file_mark_info_by_mark[previous_mark]
end

local function file_mark_info_get_next(mark)
  local idx
  local file_mark_info_by_mark, indexed_marks = get_file_mark_navigator()

  if not indexed_marks then return end

  if not mark or not indexed_marks[mark] then
    idx = 0
  else
    idx = indexed_marks[mark]
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

local function file_mark_info_jump_to_location(file_mark_info)
  if not file_mark_info then return end
  current_mark = file_mark_info.mark
  local file = file_mark_info.file
  if vim.startswith(file, "term://") then
    local bufnr = vim.fn.bufnr(file)
    require("lbrayner").jump_to_buffer(bufnr, nil, true)
    return
  end
  -- Normalized path because tilde is not expanded in lua
  file = vim.fs.normalize(file)
  local pos
  local bufnr = vim.fn.bufadd(file)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    pos = { file_mark_info.pos[2], (file_mark_info.pos[3] - 1) }
  end
  require("lbrayner").jump_to_location(file, pos, true)
end

function M.file_mark_jump_to_location(mark)
  assert(type(mark) == "string", "Bad argument; 'mark' must be a string.")
  assert(mark:match("^%u$"), "Bad argument; 'mark' must be a file mark.")
  local file_mark_info_by_mark, _ = get_file_mark_navigator()
  local file_mark_info = file_mark_info_by_mark["'"..mark]
  if not file_mark_info then
    print(string.format("“%s” is not set.", mark))
    return
  end
  file_mark_info_jump_to_location(file_mark_info)
end

local function file_mark_jump_to_previous()
  -- Try to get a different buffer
  local mark = current_mark
  for _ = 1, #get_file_mark_info_list() do
    local previous_mark_info = file_mark_info_get_previous(mark)
    mark = previous_mark_info.mark
    if not previous_mark_info then return end
    local previous_mark_bufnr = previous_mark_info.pos[1]
    if previous_mark_bufnr ~= vim.api.nvim_get_current_buf() then
      file_mark_info_jump_to_location(previous_mark_info)
      return
    end
  end
end

local function file_mark_jump_to_next()
  -- Try to get a different buffer
  local mark = current_mark
  for _ = 1, #get_file_mark_info_list() do
    local next_mark_info = file_mark_info_get_next(mark)
    mark = next_mark_info.mark
    if not next_mark_info then return end
    local next_mark_bufnr = next_mark_info.pos[1]
    if next_mark_bufnr ~= vim.api.nvim_get_current_buf() then
      file_mark_info_jump_to_location(next_mark_info)
      return
    end
  end
end

-- Commands
vim.api.nvim_create_user_command("Delfilemarks", function()
  vim.cmd("delmarks A-Z")
  current_mark = nil
 end, { nargs = 0 })

-- Mappings
vim.keymap.set("n", "]4", file_mark_jump_to_next)
vim.keymap.set("n", "[4", file_mark_jump_to_previous)

return M
