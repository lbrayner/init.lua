local M = {}

local function get_file()
  return vim.fn.fnamemodify(
    vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":p:~"
  )
end

function M.get_file_mark_info_list()
  return vim.tbl_filter(function(mark)
    return mark.mark:match("^'%u$") -- Uppercase letters
  end, vim.fn.getmarklist())
end

local function get_file_mark_info_by_mark()
  local file_mark_info_list = M.get_file_mark_info_list()

  local file_mark_info_by_mark = {}
  for _, file_mark_info in ipairs(file_mark_info_list) do
    file_mark_info_by_mark[file_mark_info.mark] = file_mark_info
  end

  return file_mark_info_by_mark
end

local function get_file_mark_navigator(opts)
  opts = opts or {}

  local file_mark_info_list = opts.file_mark_info_list or M.get_file_mark_info_list()

  if vim.tbl_isempty(file_mark_info_list) then return end

  local index_by_file = {}
  for i, file_mark_info in pairs(file_mark_info_list) do
    index_by_file[file_mark_info.file] = i
  end

  return file_mark_info_list, index_by_file
end

local function file_mark_info_get_previous(mark)
  local file = get_file()

  if file == "" then return end

  local file_mark_info_list, index_by_file = get_file_mark_navigator({
    file_mark_info_list = vim.iter(M.get_file_mark_info_list()):rev():totable()
  })
  local idx = index_by_file[file]

  if not idx then return end

  local _, next_file_mark_info = next(file_mark_info_list, idx)

  if not next_file_mark_info then
    _, next_file_mark_info = next(file_mark_info_list)
  end

  return next_file_mark_info
end

local function file_mark_info_get_next()
  local file = get_file()

  if file == "" then return end

  local file_mark_info_list, index_by_file = get_file_mark_navigator()
  local idx = index_by_file[file]

  if not idx then return end

  local _, next_file_mark_info = next(file_mark_info_list, idx)

  if not next_file_mark_info then
    _, next_file_mark_info = next(file_mark_info_list)
  end

  return next_file_mark_info
end

local function file_mark_info_jump_to_location(file_mark_info)
  if not file_mark_info then return end
  current_mark = file_mark_info.mark
  local file = file_mark_info.file
  if vim.startswith(file, "term://") then
    local bufnr = vim.fn.bufnr(file)
    require("lbrayner").jump_to_location(bufnr)
    return
  end
  -- Normalized path because tilde is not expanded in lua
  file = vim.fs.normalize(file)
  local pos
  local bufnr = vim.fn.bufadd(file)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    pos = { file_mark_info.pos[2], (file_mark_info.pos[3] - 1) }
  end
  require("lbrayner").jump_to_location(bufnr, pos)
end

function M.file_mark_jump_to_location(mark)
  assert(type(mark) == "string", "Bad argument; 'mark' must be a string.")
  assert(mark:match("^%u$"), "Bad argument; 'mark' must be a file mark.")
  local file_mark_info_by_mark = get_file_mark_info_by_mark()
  local file_mark_info = file_mark_info_by_mark["'"..mark]
  if not file_mark_info then
    vim.notify(string.format("“%s” is not set.", mark))
    return
  end
  file_mark_info_jump_to_location(file_mark_info)
end

-- Mappings
vim.keymap.set("n", "]4", function()
  local file_mark_info = file_mark_info_get_next()

  if not file_mark_info then
    vim.notify("Not currently on a marked file.", vim.log.levels.WARN)
    return
  end

  file_mark_info_jump_to_location(file_mark_info)
end)
vim.keymap.set("n", "[4", function()
  local file_mark_info = file_mark_info_get_previous()

  if not file_mark_info then
    vim.notify("Not currently on a marked file.", vim.log.levels.WARN)
    return
  end

  file_mark_info_jump_to_location(file_mark_info)
end)

return M
