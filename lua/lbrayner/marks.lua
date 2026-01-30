-- vim: fdm=marker

local M = {}

 -- {{{ Helper functions

local file_mark_info_by_bufnr = {}
local file_mark_info_by_file = {}
local file_mark_info_by_mark = {}

local function get_file()
  return vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
end

local function get_file_mark_info_by_bufnr_file_mark()
  local file_mark_info_list = M.get_file_mark_info_list()

  local file_mark_info_by_bufnr = {}
  local file_mark_info_by_mark = {}
  local file_mark_info_by_file = {}
  for _, file_mark_info in ipairs(file_mark_info_list) do
    file_mark_info_by_bufnr[file_mark_info.pos[1]] = file_mark_info
    file_mark_info_by_mark[file_mark_info.mark] = file_mark_info
    file_mark_info_by_file[file_mark_info.file] = file_mark_info
  end

  return file_mark_info_by_bufnr, file_mark_info_by_file, file_mark_info_by_mark
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

  local bufnr, pos = file_mark_info.pos[1]

  -- print("bufnr", bufnr, "file_mark_info", vim.inspect(file_mark_info))--TODO debug
  if bufnr == 0 then
    local file = file_mark_info.file

    -- Actual files (file://) are already normalized
    bufnr = vim.fn.bufadd(file)

    if not vim.api.nvim_buf_is_loaded(bufnr) and
      not vim.startswith(file, "term://") then
      pos = { file_mark_info.pos[2], (file_mark_info.pos[3] - 1) }
    end
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
    if not is_file_mark(mark.mark) then return false end

    if not require("lbrayner").is_uri(mark.file) then
      mark.file = vim.fs.normalize(mark.file)
    end

    return true
  end, vim.fn.getmarklist())
end

-- Mappings
-- Borrowed from marks.nvim (https://github.com/chentoast/marks.nvim)

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

      if vim.api.nvim_buf_is_valid(file_mark_info.pos[1]) then
        file_mark_info_jump_to_location(file_mark_info)
      else
        -- Invalid mark
        file_mark_info_by_bufnr[file_mark_info.pos[1]] = nil
        file_mark_info_by_mark[file_mark_info.mark] = nil
        file_mark_info_by_file[file_mark_info.file] = nil
      end

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
      local file_mark_info = file_mark_info_by_mark[input]

      if file_mark_info then
        file_mark_info_by_bufnr[file_mark_info.pos[1]] = nil
        file_mark_info_by_file[file_mark_info.file] = nil
      end

      local bufnr = vim.api.nvim_get_current_buf()
      local file = vim.api.nvim_buf_get_name(bufnr)
      file_mark_info_by_mark[input] = { file = file, mark = input, pos = { bufnr } }
      file_mark_info_by_bufnr[bufnr] = file_mark_info_by_mark[input]
      file_mark_info_by_file[file] = file_mark_info_by_mark[input]

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
  file_mark_info_by_bufnr,
  file_mark_info_by_file,
  file_mark_info_by_mark = get_file_mark_info_by_bufnr_file_mark()
  M.file_mark_info_by_bufnr = require(
    "lbrayner"
  ).get_proxy_table(file_mark_info_by_bufnr)
  M.file_mark_info_by_mark = require(
    "lbrayner"
  ).get_proxy_table(file_mark_info_by_mark)
  M.file_mark_info_by_file = require(
    "lbrayner"
  ).get_proxy_table(file_mark_info_by_file)
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

  local cur = vim.fn.bufadd(fmark1.file)
  local pre = vim.fn.bufadd(fmark2.file)

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

-- Autocmds

local marks = vim.api.nvim_create_augroup("marks", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = marks,
  desc = "Load file marks",
  callback = function()
    load_file_marks()

    vim.api.nvim_create_autocmd({ "BufFilePost", "BufNew" }, {
      group = marks,
      desc = "Update marks' state after buffer is created or renamed",
      callback = function(args)
        -- print("args", vim.inspect(args))--TODO debug
        local bufnr = args.buf
        local event = args.event

        if event == "BufFilePost" then
          local file_mark_info = file_mark_info_by_bufnr[bufnr]
          -- print("file_mark_info", vim.inspect(file_mark_info)) -- TODO debug

          if file_mark_info then
            file_mark_info_by_file[file_mark_info.file] = nil
            file_mark_info.file = args.file
            file_mark_info_by_file[file_mark_info.file] = file_mark_info
            -- print("file_mark_info_by_file", vim.inspect(file_mark_info_by_file)) -- TODO debug
          end
        elseif event == "BufNew" then
          local file_mark_info = file_mark_info_by_file[args.file]

          -- print("file_mark_info", vim.inspect(file_mark_info)) -- TODO debug
          if file_mark_info and file_mark_info.pos[1] == 0 then
            file_mark_info.pos[1] = bufnr
            file_mark_info_by_bufnr[bufnr] = file_mark_info
            -- print("file_mark_info_by_bufnr", vim.inspect(file_mark_info_by_bufnr)) -- TODO debug
          end
        end
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = marks })
end

return M
