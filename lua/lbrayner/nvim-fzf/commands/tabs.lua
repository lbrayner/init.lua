-- vim: fdm=marker

local FugitiveGitDir = vim.fn.FugitiveGitDir
local FugitiveResult = vim.fn.FugitiveResult
local ansi = require("lbrayner.nvim-fzf.utils").ansi
local base64_encode = vim.base64.encode
local concat = table.concat
local fnamemodify = vim.fn.fnamemodify
local get_buffer_info = require("lbrayner.nvim-fzf.utils").get_buffer_info
local get_fugitive_object = require("lbrayner.fugitive").get_fugitive_object
local get_quickfix_or_location_list_title = require(
  "lbrayner"
).get_quickfix_or_location_list_title
local getcwd = vim.fn.getcwd
local getwininfo = vim.fn.getwininfo
local is_uri = require("lbrayner").is_uri
local nvim_win_close = vim.api.nvim_win_close
local nvim_win_get_buf = vim.api.nvim_win_get_buf
local pathshorten = vim.fn.pathshorten
local relpath = vim.fs.relpath
local shellescape = vim.fn.shellescape
local tabclose = vim.cmd.tabclose
local tbl_count = vim.tbl_count
local tbl_isempty = vim.tbl_isempty

local BLUE = ansi.color_to_ansi("blue")
-- local BOLD_CYAN = ansi.color_to_ansi("cyan", "bold")
-- local BOLD_WHITE = ansi.color_to_ansi("white", "bold")
local CLEAR = ansi.clear
-- local CYAN = ansi.color_to_ansi("cyan")
local GREEN = ansi.color_to_ansi("green")
-- local ITALIC_WHITE = ansi.color_to_ansi("white", "italic")
-- local MAGENTA = ansi.color_to_ansi("magenta")
local YELLOW = ansi.color_to_ansi("yellow")
local RED = ansi.color_to_ansi("red")

local PATH_SEPARATOR = package.config:sub(1,1)
local history_file = require("lbrayner.nvim-fzf.history").get_history_file()
local state

local CHANGE_CONTEXT = "alt-c"
local CLOSE_WINDOW   = "ctrl-x"
local RELOAD         = "ctrl-r"
local TAB = ( -- {{{
  "	") -- }}}

local function get_pos(pos) -- {{{
  return ("pos(%d)"):format(pos)
end -- }}}

local function get_entry_values(entry) -- {{{
  local tabh, winid = entry:match(concat({ "^(%d+)", TAB, "(%d+)" }))
  return tonumber(tabh), tonumber(winid)
end -- }}}

local reload_action = require("fzf.actions").raw_action(function(args) -- {{{
  print("args", vim.inspect(args), vim.inspect(get_pos(state.pos)), vim.inspect(state.pos))--TODO debug
  if not tbl_isempty(args) and args[1] ~= "" then return "ignore" end

  return get_pos(state.pos)
end, "${FZF_QUERY}") -- }}}

local function get_window_name(cinfo, tinfo, winfo, binfo) -- {{{
  local function tilde(name)
    return fnamemodify(name, ":~")
  end

  local fugitive_type = vim.b[binfo.bufnr].fugitive_type

  if winfo.loclist == 1 or winfo.quickfix == 1 then
    return concat({
      winfo.loclist == 1 and "[Location List] " or "[Quickfix List] ",
      get_quickfix_or_location_list_title(winfo)
    })
  elseif binfo.name == "" then
    return "[No Name]"
  elseif fugitive_type == "blob" then -- Fugitive object
    return concat({ "[Fugitive] ", get_fugitive_object(binfo.bufnr) })
  elseif fugitive_type == "index" then -- Fugitive summary
    local name = "[Fugitive] Summary"
    local git_dir = FugitiveGitDir(binfo.bufnr):sub(1, -6)

    if cinfo.cwd ~= git_dir then
      name = concat({ name, ": ", fnamemodify(git_dir, ":~") })
    end

    return name
  elseif fugitive_type == "temp" then -- Fugitive temporary buffers
    local fugitive_result = FugitiveResult(binfo.bufnr)
    local name = concat({
      "Git", concat(fugitive_result.args, " "), fugitive_result.blame_file
    }, " ")
    local git_dir = fugitive_result.cwd

    if cinfo.cwd ~= git_dir then
      name = concat({ pathshorten(fnamemodify(git_dir, ":~")), "$ ", name })
    end

    return concat({ "[Fugitive] ", name })
  end

  if is_uri(binfo.name) then
    return binfo.name
  end

  local rel = relpath(tinfo.cwd, binfo.name)

  if not rel then
    return concat({ RED, tilde(binfo.name), CLEAR })
  end

  if cinfo.cwd == tinfo.cwd then
    return tilde(binfo.name)
  end

  return concat({ GREEN, tilde(tinfo.cwd), CLEAR, PATH_SEPARATOR, rel })
end -- }}}

local function get_window_statement(cinfo, tinfo, winfo, binfo) -- {{{
  local statement = concat({ tinfo.flags, " Tab page ", ("%-4d"):format(tinfo.tabnr) })

  -- if cinfo.tabh == tinfo.tabh then
  --   statement = concat({ RED, statement, CLEAR })
  -- end

  local dir = fnamemodify(tinfo.cwd, ":~")

  if cinfo.cwd ~= tinfo.cwd then
    dir = concat({ GREEN, dir, CLEAR })
  end

  return concat({ statement, TAB, dir, TAB, #tinfo.windows, " window(s)" })
end -- }}}

local function get_tabs() -- {{{
  local i, p = 0, 0
  local tabs = {}
  local curtabh = vim.api.nvim_get_current_tabpage()
  local curwin = vim.api.nvim_get_current_win()
  local cwd = getcwd(-1, vim.fn.tabpagenr())
  local cinfo = { cwd = cwd, tabh = curtabh }

  for tabnr, tabh in ipairs(vim.api.nvim_list_tabpages()) do
    local wins = vim.api.nvim_tabpage_list_wins(tabh)
    local tcwd = getcwd(-1, tabnr)
    -- local tab_color = cwd ~= tcwd and MAGENTA or ""
    local tinfo = {
      cwd = tcwd,
      flags = curtabh == tabh and "→" or cwd ~= tcwd and "↳" or " ",
      tabh = tabh, tabnr = tabnr, windows = wins
    }

    for _, w in ipairs(wins) do
      i = i + 1

      if p == 0 and curtabh == tabh and curwin == w then p = i end

      local winfo = getwininfo(w)[1]
      local bufnr = nvim_win_get_buf(w)
      local binfo = get_buffer_info(bufnr)
      -- local statement = base64_encode(get_window_statement(cwd, tinfo, winfo, binfo))
      -- local statement = get_window_statement(cwd, tinfo, winfo, binfo)
      -- statement = base64_encode(statement ~= "" and concat({ ": ", statement }) or statement)

      table.insert(
        tabs,
        ("%d	%d	%d	%s	%s%s%4d%s	%s	%d	%s%6s%s	%s	%s"):format(
          tabh, w, i, base64_encode(get_window_statement(cinfo, tinfo, winfo, binfo)),
          tinfo.flags, YELLOW, tabnr, CLEAR, p == i and "★" or "", w,
          BLUE, concat({ "[", bufnr, "]" }), CLEAR,
          binfo.flags, get_window_name(cinfo, tinfo, winfo, binfo)
        )
      )
    end
  end

  state.pos = p
  state.tabs = tabs
  return tabs
end

-- local get_tabs_action = require("fzf.actions").raw_action(get_tabs) -- }}}

local load_action = require("fzf.actions").raw_action(function() -- {{{
  -- print("state", vim.inspect(state))--TODO debug
  -- print("load!")--TODO debug
  if not state.cpos then return "ignore" end
  local action = get_pos(state.cpos)
  state.cpos = nil
  return action
end) -- }}}

local change_context_action = require("fzf.actions").raw_action(function(args) -- {{{
  -- print("args", vim.inspect(args), vim.inspect(get_pos(state.pos)), vim.inspect(state.pos))--TODO debug
  -- if not tbl_isempty(args) and args[1] ~= "" then
  --   return "ignore"
  -- end
  if tbl_count(args) == 1 then return state.tabs end
  -- local fzf_pos = tonumber(args[1])
  -- if fzf_pos == state.pos then return "ignore" end
  -- if tbl_isempty(args) or args[1] == "" then return "ignore" end
  -- local command = concat({ "clear-query+", get_pos() })
  -- print("command", vim.inspect(command))--TODO debug

  -- local _, _, pos = get_entry_values(args[1])
  -- local pos = tonumber(args[1])
  state.cpos = tonumber(args[1])
  -- local command = ("clear-query+reload-sync(%s)+pos(%d)"):format(get_tabs_action, pos)
  -- print("pos", vim.inspect(pos), "command", vim.inspect(command))--TODO debug

  return state.tabs
end, "{3} ${FZF_QUERY} {}") -- }}}

local function close_window(selected) -- {{{
  local function close(selected)
    local count = 0

    vim.iter(selected):each(function(s)
      local _, winid = get_entry_values(s)
      local success, _ = pcall(nvim_win_close, winid, false)
      if success then count = count + 1 end
    end)

    vim.notify(concat({ "[FZF tabs] Closed ", count, " window(s)" }))
  end

  if #selected <= 10 then
    close(selected)
  else
    vim.notify(
      "[FZF tabs] Close window: exceeded limit of 10 selected items",
      vim.log.levels.ERROR
    )
    return
  end

  return get_tabs()
end

local close_window_action = require("fzf.actions").raw_action(close_window) -- }}}

local function jump(selected) -- {{{
  if #selected > 1 then
    vim.notify("[FZF tabs] Cannot jump to multiple windows", vim.log.levels.WARN)
    return
  end

  local tabh, winid = get_entry_values(selected[1])

  vim.api.nvim_set_current_tabpage(tabh)
  vim.api.nvim_set_current_win(winid)
end -- }}}

return function (opts)
  opts = opts or {}
  state = {}
  local tabs = get_tabs()
  local pos = get_pos(state.pos)
  local fzf_cli_args = concat({
    "--ansi --multi --sync --prompt='Tabs> '",
    concat({ "--history=", shellescape(history_file) }),
    concat({
      "--bind=",
      shellescape(concat({
        "start:%s,load:transform(%s),",
        "%s:clear-query+reload(%s),%s:transform(%s),%s:reload(%s)"
      }):format(
        pos, load_action,
        CHANGE_CONTEXT, change_context_action,
        RELOAD, reload_action,
        CLOSE_WINDOW, close_window_action
      ))
    }),
    concat({ "--delimiter=", shellescape(TAB) }),
    "--with-nth=5..",
    concat({ "--preview=", shellescape([[echo {4} | base64 -d -]]) }),
    "--preview-window=nohidden:up,1" ,
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  coroutine.wrap(function()
    local selected = require("fzf").fzf(tabs, fzf_cli_args)
    state = nil

    if selected then
      jump(selected)
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
