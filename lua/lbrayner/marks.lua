local M = {}

local function get_file_mark_info_list()
  return vim.tbl_filter(function(mark)
    return mark.mark:match("^'%u$") -- Uppercase letters
  end, vim.fn.getmarklist())
end

local function get_file_mark_navigator(opts)
  opts = opts or {}

  local file_mark_info_list = opts.file_mark_info_list or get_file_mark_info_list()

  if vim.tbl_isempty(file_mark_info_list) then return end

  local index_by_file = {}
  for i, file_mark_info in pairs(file_mark_info_list) do
    index_by_file[file_mark_info.file] = i
  end

  return file_mark_info_list, index_by_file
end

local function file_mark_info_get_previous(mark)
  local file = vim.fn.fnamemodify(
    vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":p:~"
  )

  if file == "" then return end

  local file_mark_info_list, index_by_file = get_file_mark_navigator({
    file_mark_info_list = vim.iter(get_file_mark_info_list()):rev():totable()
  })
  local idx = index_by_file[file]

  if not idx then return end

  local _, next_file_mark_info = next(file_mark_info_list, idx)
  return next_file_mark_info
end

local function file_mark_info_get_next()
  local file = vim.fn.fnamemodify(
    vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":p:~"
  )

  if file == "" then return end

  local file_mark_info_list, index_by_file = get_file_mark_navigator()
  local idx = index_by_file[file]

  if not idx then return end

  local _, next_file_mark_info = next(file_mark_info_list, idx)
  return next_file_mark_info
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
  require("lbrayner").jump_to_location(file, pos)
end

function M.file_mark_jump_to_location(mark)
  assert(type(mark) == "string", "Bad argument; 'mark' must be a string.")
  assert(mark:match("^%u$"), "Bad argument; 'mark' must be a file mark.")
  local file_mark_info_by_mark, _ = get_file_mark_navigator()
  local file_mark_info = file_mark_info_by_mark["'"..mark]
  if not file_mark_info then
    vim.notify(string.format("“%s” is not set.", mark))
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
  for _ = 1, #get_file_mark_info_list() do
    local next_mark_info = file_mark_info_get_next()
    mark = next_mark_info.mark
    if not next_mark_info then return end
    local next_mark_bufnr = next_mark_info.pos[1]
    if next_mark_bufnr ~= vim.api.nvim_get_current_buf() then
      file_mark_info_jump_to_location(next_mark_info)
      return
    end
  end
end

-- Mappings
vim.keymap.set("n", "]4", function()
  print(vim.inspect(file_mark_info_get_next()))
end)
vim.keymap.set("n", "[4", function()
  print(vim.inspect(file_mark_info_get_previous()))
end)

return M
