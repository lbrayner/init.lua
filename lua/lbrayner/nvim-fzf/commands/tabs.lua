-- vim: fdm=marker

-- {{{ Localizations

local FugitiveGitDir = vim.fn.FugitiveGitDir
local FugitiveParse = vim.fn.FugitiveParse
local FugitiveResult = vim.fn.FugitiveResult
local ansi = require("lbrayner.nvim-fzf.utils").ansi
local base64_encode = vim.base64.encode
local concat = table.concat
local fnamemodify = vim.fn.fnamemodify
local get_buffer_info = require("lbrayner.nvim-fzf.utils").get_buffer_info
local get_quickfix_or_location_list_title = require(
  "lbrayner"
).get_quickfix_or_location_list_title
local getcwd = vim.fn.getcwd
local getwininfo = vim.fn.getwininfo
local is_uri = require("lbrayner").is_uri
local nvim_buf_get_name = vim.api.nvim_buf_get_name
local nvim_win_close = vim.api.nvim_win_close
local nvim_win_get_buf = vim.api.nvim_win_get_buf
local relpath = vim.fs.relpath
local shellescape = vim.fn.shellescape
local tabclose = vim.cmd.tabclose
local tbl_count = vim.tbl_count
local tbl_isempty = vim.tbl_isempty

-- }}}

local BLUE = ansi.color_to_ansi("blue")
local CLEAR = ansi.clear
local GREEN = ansi.color_to_ansi("green")
local YELLOW = ansi.color_to_ansi("yellow")
local RED = ansi.color_to_ansi("red")

local TAB = ( -- {{{
  "	") -- }}}
local history_file = require("lbrayner.nvim-fzf.history").get_history_file()
local state

local CHANGE_CONTEXT = "alt-c"
local CLOSE_WINDOW   = "ctrl-x"
local RESET          = "ctrl-r"

local function get_pos(pos) -- {{{
  return ("pos(%d)"):format(pos)
end -- }}}

local function get_entry_values(entry) -- {{{
  local tabh, winid = entry:match(concat({ "^(%d+)", TAB, "(%d+)" }))
  return tonumber(tabh), tonumber(winid)
end -- }}}

local function get_window_name(cinfo, tinfo, winfo, binfo) -- {{{
  local function tilde(name)
    return fnamemodify(name, ":~")
  end

  if winfo.loclist == 1 or winfo.quickfix == 1 then
    return concat({
      winfo.loclist == 1 and "[Location List] " or "[Quickfix List] ",
      get_quickfix_or_location_list_title(winfo)
    })
  elseif binfo.name == "" then
    return "[No Name]"
  elseif vim.b[binfo.bufnr].fugitive_type then
    local fugitive_type, fugitive = vim.b[binfo.bufnr].fugitive_type

    if fugitive_type == "blob" then -- Fugitive summary
      local fugitive_object = FugitiveParse(nvim_buf_get_name(binfo.bufnr))
      fugitive = { cwd = fugitive_object[2]:sub(1, -6), name = fugitive_object[1] }
    elseif fugitive_type == "index" then -- Fugitive summary
      fugitive = { cwd = FugitiveGitDir(binfo.bufnr):sub(1, -6), name = "Summary" }
    elseif fugitive_type == "temp" then -- Fugitive temporary buffers
      fugitive = FugitiveResult(binfo.bufnr)
      fugitive.name = concat({
        "Git", concat(fugitive.args, " "), fugitive.blame_file
      }, " ")
    else
      error(concat({ "[FZF tabs] Unknow fugitive type: ", fugitive_type }))
    end

    if cinfo.cwd == fugitive.cwd then
      return concat({
        "📁 ", tilde(fugitive.cwd), TAB, "[Fugitive] ", fugitive.name
      })
    end

    if tinfo.cwd == fugitive.cwd then
      return concat({
        "📁 ", GREEN, tilde(fugitive.cwd), CLEAR, TAB, "[Fugitive] ", fugitive.name
      })
    end

    local rel = relpath(tinfo.cwd, fugitive.cwd)

    if not rel then
      return concat({
        "📁 ", RED, tilde(fugitive.cwd), CLEAR, TAB, "[Fugitive] ", fugitive.name
      })
    end

    return concat({
      "📁 ", tilde(fugitive.cwd), TAB, "[Fugitive] ", fugitive.name
    })
  end

  if is_uri(binfo.name) then
    return binfo.name
  end

  local rel = relpath(tinfo.cwd, binfo.name)

  if not rel then
    return concat({ RED, tilde(binfo.name), CLEAR })
  end

  if cinfo.cwd == tinfo.cwd then
    return concat({ "📁 ", tilde(tinfo.cwd), TAB, rel })
  end

  return concat({ "📁 ", GREEN, tilde(tinfo.cwd), CLEAR, TAB, rel })
end -- }}}

local function get_window_statement(cinfo, tinfo, winfo) -- {{{
  local statement = concat({ tinfo.flags, " Tab page ", ("%-4d"):format(tinfo.tabnr) })

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

      table.insert(
        tabs,
        ("%d	%d	%d	%s	%s%s%4d%s	%s	%d	%s%6s%s	%s	%s"):format(
          tabh, w, i, base64_encode(get_window_statement(cinfo, tinfo, winfo)),
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
end -- }}}

local reload_action = require("fzf.actions").raw_action(function()
  return state.tabs
end)

local change_context_action = require("fzf.actions").raw_action(function(args) -- {{{
  if tbl_count(args) == 1 then return "ignore" end

  state.cpos = tonumber(args[1])

  return ("clear-query+reload(%s)"):format(reload_action)
end, [[{3} ${FZF_QUERY}]]) -- }}}

local close_window_action = require("fzf.actions").raw_action(function(selected) -- {{{
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
end) -- }}}

local function jump(selected) -- {{{
  if #selected > 1 then
    vim.notify("[FZF tabs] Cannot jump to multiple windows", vim.log.levels.WARN)
    return
  end

  local tabh, winid = get_entry_values(selected[1])

  vim.api.nvim_set_current_tabpage(tabh)
  vim.api.nvim_set_current_win(winid)
end -- }}}

local load_action = require("fzf.actions").raw_action(function() -- {{{
  if not state.cpos then return "ignore" end
  local action = get_pos(state.cpos)
  state.cpos = nil
  return action
end) -- }}}

local reset_action = require("fzf.actions").raw_action(function(args) -- {{{
  if not tbl_isempty(args) and args[1] ~= "" then return "ignore" end

  return get_pos(state.pos)
end, "${FZF_QUERY}") -- }}}

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
        "%s:transform(%s),%s:transform(%s),%s:reload(%s)"
      }):format(
        pos, load_action,
        CHANGE_CONTEXT, change_context_action,
        RESET, reset_action,
        CLOSE_WINDOW, close_window_action
      ))
    }),
    concat({ "--delimiter=", shellescape(TAB) }),
    "--with-nth=5..",
    concat({ "--preview=", shellescape([[echo {4} | base64 -d -]]) }),
    "--preview-window=nohidden:up,1" ,
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")

  coroutine.wrap(function()
    local selected = require("fzf").fzf(tabs, fzf_cli_args)
    state = nil

    if selected then
      jump(selected)
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
