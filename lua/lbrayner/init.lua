local M = {}

function M.buffer_is_scratch(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.bo[bufnr].buftype == "nofile" and
  vim.tbl_contains({ "hide", "wipe" }, vim.bo[bufnr].bufhidden) and
  vim.bo[bufnr].swapfile == false
end

function M.contains(s, text)
  vim.validate({ s = { s, 's' }, text = { text, 's' } })
  return string.find(s, text, 1, true)
end

function M.diff_include_expression(fname)
  fname = vim.fn.tr(fname, ".", "/")
  if vim.fn.isdirectory("lua") == 1 then
    local init = vim.fs.joinpath("lua", fname, "init.lua")
    if vim.fn.filereadable(init) == 1 then
      return init
    end
    return vim.fs.joinpath("lua", fname)
  end
  return fname
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

function M.get_session()
  -- vim-obsession
  local session = string.gsub(vim.v.this_session, "%.%d+%.obsession~?", "")
  if session ~= "" then
    return vim.fn.fnamemodify(session, ":t:r")
  end
  return ""
end

-- From vim.lsp.util.bufwinid
local function bufwinid(bufnr)
  local win = vim.fn.bufwinid(bufnr)
  if win > 0 then return win end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
end

local function _jump_to_location(win, bufnr, pos, flash)
  -- From vim.lsp.util.show_document
  -- Save position in jumplist
  if vim.bo.buftype ~= "terminal" then -- TODO debug to find the real cause
    vim.cmd("normal! m'")
  end

  vim.bo[bufnr].buflisted = true
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.api.nvim_set_current_win(win)
  if pos then
    vim.api.nvim_win_set_cursor(win, pos)
    vim.api.nvim_win_call(win, function()
      -- Open folds under the cursor
      vim.cmd("normal! zv")
    end)
  end

  if flash and not require("lbrayner.flash").is_flash_window_mode() then
    require("lbrayner.flash").flash_window()
  end
end

function M.is_in_directory(node, directory, exclusive)
  local full_node = vim.fs.normalize(vim.fn.fnamemodify(node, ":p"))
  local full_directory = vim.fs.normalize(vim.fn.fnamemodify(directory, ":p"))
  if exclusive and full_node == full_directory  then
    return false
  end
  return vim.startswith(full_node, full_directory)
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

-- TODO from tint.nvim, still not used
function M.iterate_all_windows(func)
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    if vim.api.nvim_tabpage_is_valid(tabpage) then
      for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
        if vim.api.nvim_win_is_valid(winid) then
          func(winid, tabpage)
        end
      end
    end
  end
end

function M.jump_to_buffer(bufnr, pos, flash)
  local win = bufwinid(bufnr)
  _jump_to_location(win, bufnr, pos, flash)
end

function M.jump_to_location(filename, pos, flash)
  local bufnr = vim.fn.bufadd(filename)
  local win = bufwinid(bufnr)

  if not win then
    vim.ui.select({
      { command = "buffer", description = "Current window" },
      { command = "new", description = "Horizontal split" },
      { command = "vnew", description = "Vertical split" },
      { command = "tabnew", description = "Tab" } }, {
      prompt = string.format("Open %s in:", vim.fn.fnamemodify(filename, ":~:.")),
      format_item = function(open_cmd) return open_cmd.description end,
    }, function(open_cmd)
      if not open_cmd then
        return
      end

      -- From vim.lsp.util.create_window_without_focus
      local prev = vim.api.nvim_get_current_win()
      vim.cmd(open_cmd.command)
      win = vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(prev)

      _jump_to_location(win, bufnr, pos, flash)
    end)
    return
  end

  _jump_to_location(win, bufnr, pos, flash)
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

-- From fzf-lua utils
function M.read_file(filepath)
  local fd = vim.uv.fs_open(filepath, "r", 438)
  if fd == nil then return "" end
  local stat = assert(vim.uv.fs_fstat(fd))
  if stat.type ~= "file" then return "" end
  local data = assert(vim.uv.fs_read(fd, stat.size, 0))
  assert(vim.uv.fs_close(fd))
  return data
end

function M.setup_matchit()
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

function M.truncate_filename(filename, maxlength)
  if string.len(filename) <= maxlength then
    return filename
  end
  local head = vim.fn.fnamemodify(filename, ":h")
  local tail = vim.fn.fnamemodify(filename, ":t")
  if head ~= "." and string.len(tail) < maxlength then
    -- -1 (horizontal ellipsis …), -1 (forward slash)
    return string.sub(head, 1, maxlength - string.len(tail) - 1 -1) .. "…/" .. tail
  end
  local cut = maxlength / 2
  return string.sub(tail, 1, cut - 1) .. "…" .. string.sub(tail, cut)
end

function M.window_is_floating()
  return vim.api.nvim_win_get_config(0).relative ~= ""
end

return M
