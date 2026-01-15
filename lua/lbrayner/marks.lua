-- vim: fdm=marker

local M = {}

 -- {{{ Helper functions

local function get_file()
  return vim.fn.fnamemodify(
    vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":p:~"
  )
end

local function get_file_mark_info_by_mark_bufnr()
  local file_mark_info_list = M.get_file_mark_info_list()

  local file_mark_info_by_mark = {}
  local file_mark_info_by_bufnr = {}
  for _, file_mark_info in ipairs(file_mark_info_list) do
    file_mark_info_by_mark[file_mark_info.mark] = file_mark_info
    file_mark_info_by_bufnr[file_mark_info.pos[1]] = file_mark_info
  end

  return file_mark_info_by_mark, file_mark_info_by_bufnr
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

local function is_file_mark(input)
  return input:match("^%u$") -- Uppercase letters
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

local function file_mark_move_down_info()
  local file = get_file()

  if file == "" then return end

  local file_mark_info_list, index_by_file = get_file_mark_navigator()
  local idx = index_by_file[file]

  if not idx then return end

  local file_mark_info = file_mark_info_list[idx]
  local _, next_file_mark_info = next(file_mark_info_list, idx)

  if not next_file_mark_info then
    _, next_file_mark_info = next(file_mark_info_list)
  end

  return file_mark_info, next_file_mark_info
end

local function file_mark_move_up_info()
  local file = get_file()

  if file == "" then return end

  local file_mark_info_list, index_by_file = get_file_mark_navigator({
    file_mark_info_list = vim.iter(M.get_file_mark_info_list()):rev():totable()
  })
  local idx = index_by_file[file]

  if not idx then return end

  local file_mark_info = file_mark_info_list[idx]
  local _, previous_file_mark_info = next(file_mark_info_list, idx)

  if not previous_file_mark_info then
    _, previous_file_mark_info = next(file_mark_info_list)
  end

  return file_mark_info, previous_file_mark_info
end

-- }}}

function M.file_mark_jump_to_location(mark)
  assert(type(mark) == "string", "Bad argument; 'mark' must be a string.")
  assert(mark:match("^%u$"), "Bad argument; 'mark' must be a file mark.")
  local file_mark_info_by_mark = get_file_mark_info_by_mark_bufnr()
  local file_mark_info = file_mark_info_by_mark[mark]
  if not file_mark_info then
    vim.notify(string.format("“%s” is not set.", mark))
    return
  end
  file_mark_info_jump_to_location(file_mark_info)
end

function M.get_file_mark_info_list()
  return vim.tbl_filter(function(mark)
    mark.mark = (mark.mark):sub(2)
    return is_file_mark(mark.mark)
  end, vim.fn.getmarklist())
end

-- Mappings
-- Borrowed from marks.nvim (https://github.com/chentoast/marks.nvim)

local file_mark_info_by_bufnr = {}
local file_mark_info_by_mark = {}
local utils = require("lbrayner.marks.utils")

vim.keymap.set("n", "'", function()
  -- From mini.nvim jump
  local needs_help_msg = true

  vim.defer_fn(function()
    if not needs_help_msg then return end
    -- Echo. Force redraw to ensure that it is effective (`:h echo-redraw`)
    vim.cmd([[echo '' | redraw]])
    print("[Jump to mark] Enter mark: ")
  end, 1000)

  local success, input = pcall(vim.fn.getcharstr)
  needs_help_msg = false
  -- Unecho
  vim.cmd([[echo '' | redraw]])

  if not success then
    return
  end

  if utils.is_valid_mark(input) then
    if is_file_mark(input) then
      local file_mark_info = file_mark_info_by_mark[input]

      if not file_mark_info then return end

      require("lbrayner").jump_to_location(file_mark_info.pos[1])
      return
    end

    vim.cmd("normal! '" .. input)
  end
end)
vim.keymap.set("n", "m", function()
  -- From mini.nvim jump
  local needs_help_msg = true

  vim.defer_fn(function()
    if not needs_help_msg then return end
    -- Echo. Force redraw to ensure that it is effective (`:h echo-redraw`)
    vim.cmd([[echo '' | redraw]])
    print("[Set mark] Enter mark: ")
  end, 1000)

  local success, input = pcall(vim.fn.getcharstr)
  needs_help_msg = false
  -- Unecho
  vim.cmd([[echo '' | redraw]])

  if not success then
    return
  end

  if utils.is_valid_mark(input) then
    vim.cmd("normal! m" .. input)

    if is_file_mark(input) then
      local bufnr = vim.api.nvim_get_current_buf()

      file_mark_info_by_mark[input] = { mark = input, pos = { bufnr } }
      file_mark_info_by_bufnr[bufnr] = file_mark_info_by_mark[input]

      vim.api.nvim_exec_autocmds("User", { pattern = "FileMarkSet" })
    end
  end
end)

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

local function load_file_marks() -- {{{
  file_mark_info_by_mark, file_mark_info_by_bufnr = get_file_mark_info_by_mark_bufnr()
  M.file_mark_info_by_bufnr = setmetatable(
    {},
    {
      __index = file_mark_info_by_bufnr,
      __newindex = function()
        error("Cannot add item")
      end,
    }
  )
  M.file_mark_info_by_mark = setmetatable(
    {},
    {
      __index = file_mark_info_by_mark,
      __newindex = function()
        error("Cannot add item")
      end,
    }
  )
end -- }}}

local function swap_marks(fmark1, fmark2) -- {{{
  if not fmark1 then
    vim.notify("Not currently on a marked file.", vim.log.levels.WARN)
    return
  end

  if not fmark2 then
    vim.notify("There is only one file mark.", vim.log.levels.WARN)
    return
  end

  local cur = vim.fn.bufadd(vim.fs.normalize(fmark1.file))
  local pre = vim.fn.bufadd(vim.fs.normalize(fmark2.file))

  local restore = function()
    vim.api.nvim_buf_set_mark(
      cur,
      fmark1.mark,
      fmark1.pos[2],
      fmark1.pos[3] - 1,
      {}
    )
  end

  local success, err = pcall(
    vim.api.nvim_buf_set_mark,
    cur,
    fmark2.mark,
    fmark1.pos[2],
    fmark1.pos[3] - 1,
    {}
  ) or pcall(
    vim.api.nvim_buf_set_mark,
    cur,
    fmark2.mark,
    1, 0, {}
  )

  if not success then
    restore()
    error(err)
  end

  success, err = pcall(
    vim.api.nvim_buf_set_mark,
    pre,
    fmark1.mark,
    fmark2.pos[2],
    fmark2.pos[3] - 1,
    {}
  )

  if not success then
    restore()
    error(err)
  end

  load_file_marks()
  vim.api.nvim_exec_autocmds("User", { pattern = "FileMarkSet" })
  print("Swapped file mark", fmark1.mark, "with", fmark2.mark)
end -- }}}

vim.keymap.set("n", "<A-4>", function()
  local file_mark_info, next_file_mark_info = file_mark_move_down_info()
  swap_marks(file_mark_info, next_file_mark_info)
end)
vim.keymap.set("n", "<A-$>", function()
  local file_mark_info, previous_file_mark_info = file_mark_move_up_info()
  swap_marks(file_mark_info, previous_file_mark_info)
end)

vim.api.nvim_create_user_command("Delmarks", function(opts)
  local args = opts.args
  vim.cmd.delmarks(args)

  if args:match("%u") then
    load_file_marks()
  end
end, { bar = true, nargs = 1 })

vim.keymap.set("ca", "delmarks", "Delmarks")

local marks = vim.api.nvim_create_augroup("marks", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = marks,
  desc = "Load file marks",
  callback = load_file_marks,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = marks })
end

return M
