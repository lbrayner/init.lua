local M = {}

local concat = table.concat
local fnamemodify = vim.fn.fnamemodify
local nvim_buf_get_mark = vim.api.nvim_buf_get_mark
local nvim_buf_get_text = vim.api.nvim_buf_get_text
local nvim_get_current_buf = vim.api.nvim_get_current_buf
local tbl_contains = vim.tbl_contains

function M.buf_is_scratch(bufnr)
  bufnr = bufnr or nvim_get_current_buf()

  return (
    vim.bo[bufnr].buftype == "nofile" and
    tbl_contains({ "hide", "wipe" }, vim.bo[bufnr].bufhidden) and
    vim.bo[bufnr].swapfile == false
  )
end

function M.contains(s, text)
  vim.validate({ s = { s, 's' }, text = { text, 's' } })
  return string.find(s, text, 1, true)
end

function M.get_close_events()
  return { "CursorMoved", "CursorMovedI", "InsertCharPre", "WinScrolled" }
end

function M.get_quickfix_or_location_list_title(winid)
  winid = winid or vim.api.nvim_get_current_win()
  if not M.is_quickfix_or_location_list(winid) then
    return ""
  end
  if M.is_location_list() then
    return vim.fn.getloclist(winid, { title = 1 }).title
  end
  return vim.fn.getqflist({ title = 1 }).title
end

function M.get_path(bufnr)
  bufnr = bufnr or 0
  local path = require("lbrayner.fugitive").get_fugitive_object(bufnr)

  if path then
    return path
  end

  if vim.startswith(vim.api.nvim_buf_get_name(bufnr), "jdt://") then -- jdtls
    return require("lbrayner.jdtls").get_buffer_name(bufnr)
  end

  return require("lbrayner.path").get_path(bufnr)
end

function M.get_proxy_table_for_module(module)
  return setmetatable({}, {
    __index = function(_, key)
      return require(module)[key]
    end,
    __newindex = function()
      error("Cannot add item")
    end,
  })
end

function M.get_session()
  -- vim-obsession
  local session = string.gsub(vim.v.this_session, "%.%d+%.obsession~?", "")
  if session ~= "" then
    return fnamemodify(session, ":t:r")
  end
  return ""
end

function M.get_visual_selection(usr_cmd, opts)
  assert(type(usr_cmd) == "table", "'usr_cmd' must be a table")
  assert(not opts or type(opts) == "table", "'opts' must be a table")
  opts = opts or {}

  if usr_cmd.count <= 0 then
    return
  end

  local line1 = usr_cmd.line1
  local line2 = usr_cmd.line2
  local pos_start = nvim_buf_get_mark(0, "<")
  local pos_end = nvim_buf_get_mark(0, ">")

  if line1 ~= pos_start[1] or line2 ~= pos_end[1] then
    -- line range was supplied
    return false, 1
  end

  if not opts.multi_line and pos_start[1] ~= pos_end[1] then
    -- multi-line selection
    return false, 2
  end

  local start_row = pos_start[1] - 1
  local start_col = pos_start[2]
  local end_row = pos_end[1] - 1
  local end_col = pos_end[2] + 1
  local visual_selection = nvim_buf_get_text(
    0, start_row, start_col, end_row, end_col, {}
  )

  return true, visual_selection
end

local function _jump_to_window_or_unhide(winid, bufnr, pos)
  -- From vim.lsp.util.show_document
  -- Save position in jumplist
  if vim.bo.buftype ~= "terminal" then -- TODO debug to find the real cause
    vim.cmd("normal! m'")
  end

  vim.bo[bufnr].buflisted = true
  vim.api.nvim_win_set_buf(winid, bufnr)
  vim.api.nvim_set_current_win(winid)
  if pos then
    vim.api.nvim_win_set_cursor(winid, pos)
    vim.api.nvim_win_call(winid, function()
      -- Open folds under the cursor
      vim.cmd("normal! zv")
    end)
  end
end

function M.include_expression(fname)
  fname = vim.fn.tr(fname, ".", "/")
  local dir = "lua"

  if vim.fn.isdirectory(dir) == 0 then
    dir = "vim/dot-local/share/nvim/site/lua"

    if vim.fn.isdirectory(dir) == 0 then
      dir = nil
    end
  end

  if not dir then
    return fname
  end

  local init = vim.fs.joinpath(dir, fname, "init.lua")

  if vim.uv.fs_stat(init) then
    return init
  end

  local module = vim.fs.joinpath(dir, fname .. ".lua")

  if vim.uv.fs_stat(module) then
    return module
  end

  return vim.fs.joinpath(dir, fname)
end

function M.is_location_list(winid)
  winid = winid or vim.api.nvim_get_current_win()
  return vim.fn.getwininfo(winid)[1]["loclist"] == 1
end

function M.is_quickfix_list(winid)
  winid = winid or vim.api.nvim_get_current_win()
  return vim.fn.getwininfo(winid)[1]["quickfix"] == 1 and vim.fn.getwininfo(winid)[1]["loclist"] == 0
end

function M.is_quickfix_or_location_list(winid)
  winid = winid or vim.api.nvim_get_current_win()
  return vim.fn.getwininfo(winid)[1]["quickfix"] == 1
end

function M.join(col)
  assert(type(col) == "table", "Bad argument; 'col' must be a table.")
  return table.concat(col, " ")
end

function M.jump_to_location(bufnr, pos, opts)
  assert(type(bufnr) == "number", "Bad argument; 'bufnr' must be a number.")

  opts = opts or {}
  local winid = vim.fn.win_findbuf(bufnr)[1]

  local function open(command)
    if not command then return end

    local winid = 0

    if command ~= "" then
      -- from fzf-lua's actions (vimcmd_entry)
      vim.cmd(concat({ command, " | setlocal bufhidden=wipe | buffer ", bufnr }))
      winid = vim.api.nvim_get_current_win()
    end

    _jump_to_window_or_unhide(winid, bufnr, pos)
  end

  if winid then
    _jump_to_window_or_unhide(winid, bufnr, pos)
    return
  end

  if opts.open_cmd then
    open(opts.open_cmd)
    return
  end

  local name = M.get_path(bufnr)

  if vim.startswith(vim.uri_from_bufnr(bufnr), "file://") then
    name = vim.fn.pathshorten(name)
  end

  vim.ui.select(
    {
      { command = "", description = "Current window" },
      { command = "new", description = "Horizontal split" },
      { command = "vnew", description = "Vertical split" },
      { command = "-tabnew", description = "Tab before" },
      { command = "tabnew", description = "Tab" },
    },
    {
      prompt = string.format("Open %s in:", name),
      format_item = function(selected) return selected.description end,
    },
    function(selected)
      open(selected and selected.command)
    end
  )
end

local function navigate_depth_parent(n)
  vim.cmd("silent normal! v"..(n+1).."atb")
  vim.cmd([[exec "silent normal! \<Esc>"]])
end

function M.navigate_depth(depth) -- TODO not working
  if depth < 0 then
    M.navigate_depth_backward(-depth)
    return
  end
  navigate_depth_parent(depth)
end

function M.navigate_depth_backward(depth)
  if depth < 0 then
    M.navigate_depth(-depth)
    return
  end
  M.navigate_depth(depth)
  vim.fn["matchit#Match_wrapper"]("", 1, "n")
end

function M.options(...)
  local arg = { ... }
  for _, value in pairs(arg) do
    if value then
      if type(value) == "string" then
        if value ~= "" then
          return value
        end
      else
        return value
      end
    end
  end
end

function M.preserve_view_port(command)
  local lazyr = vim.go.lazyredraw
  local winview = vim.fn.winsaveview()
  local success, err = pcall(command)

  if success then
    vim.fn.winrestview(winview)
  end

  vim.go.lazyredraw = lazyr

  if not success then
    error(err)
  end
end

-- https://docs.otland.net/lua-guide/auxiliary/optimizations
function M.push(t, e)
  assert(type(t) == "table", "Bad argument; 't' must be a table.")
  t[#t+1] = e
end

function M.set_number()
  local number = vim.wo.number
  local relativenumber = vim.wo.relativenumber
  vim.wo.number = true
  vim.wo.relativenumber = true
  -- setting nonumber if length of line count is greater than 3
  if #tostring(vim.fn.line("$")) > 3 then
    vim.wo.number = false
  end

  return number ~= vim.wo.relativenumber or relativenumber ~= vim.wo.relativenumber
end

function M.setup_xml_matchit()
  if vim.g.loaded_matchit == 1 then
    vim.b.match_ignorecase = 0
    vim.b.match_words = [[<:>,]] ..
    [[<\@<=!\[CDATA\[:]] .. "]]>," ..
    [[<\@<=!--:-->,]] ..
    [[<\@<=?\k\+:?>,]] ..
    [[<\@<=\([^ \t>/]\+\)\%(\s\+[^>]*\%([^/]>\|$\)\|>\|$\):<\@<=/\1>,]] ..
    [[<\@<=\%([^ \t>/]\+\)\%(\s\+[^/>]*\|$\):/>]]
  end
end

function M.synstack()
  local pos = vim.api.nvim_win_get_cursor(0)
  local synstack = vim.fn.synstack(pos[1], pos[2] + 1)
  local syn_id_addrs = vim.tbl_map(function(item)
    return vim.fn.synIDattr(item, "name")
  end, synstack)
  return syn_id_addrs
end

function M.truncate_filename(filename, maxlength)
  if string.len(filename) <= maxlength then
    return filename
  end
  local head = fnamemodify(filename, ":h")
  local tail = fnamemodify(filename, ":t")
  if head ~= "." and string.len(tail) < maxlength then
    -- -1 (horizontal ellipsis …), -1 (forward slash)
    return string.sub(head, 1, maxlength - string.len(tail) - 1 -1) .. "…/" .. tail
  end
  local cut = maxlength / 2
  return string.sub(tail, 1, cut - 1) .. "…" .. string.sub(tail, cut)
end

function M.win_is_actual_curwin()
  -- This variable is defined by the runtime.
  -- :h g:actual_curwin
  if vim.g.actual_curwin and vim.g.actual_curwin ~= vim.api.nvim_get_current_win() then
    return false
  end

  return true
end

function M.win_is_floating()
  return vim.api.nvim_win_get_config(0).relative ~= ""
end

return M
