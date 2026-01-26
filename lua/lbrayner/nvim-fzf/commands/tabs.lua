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
local nvim_win_close = vim.api.nvim_win_close
local nvim_win_get_buf = vim.api.nvim_win_get_buf
local pathshorten = vim.fn.pathshorten
local relpath = vim.fs.relpath
local shellescape = vim.fn.shellescape
local tabclose = vim.cmd.tabclose

local BLUE = ansi.color_to_ansi("blue")
local BOLD_CYAN = ansi.color_to_ansi("cyan", "bold")
local BOLD_YELLOW = ansi.color_to_ansi("yellow", "bold")
local CLEAR = ansi.clear
local WHITE = ansi.color_to_ansi("white")
local history_file = require("lbrayner.nvim-fzf.history").get_history_file()

local CLOSE_WINDOW = "ctrl-x"
local RELOAD       = "ctrl-r"
local TAB = ( -- {{{
  "	") -- }}}

local function get_entry_values(entry) -- {{{
  local tabh, winid, tabn = entry:match(concat({ "^(%d+)", TAB, "(%d+)", TAB, "(%d+)" }))
  return tonumber(tabh), tonumber(winid), tonumber(tabn)
end -- }}}

local function get_window_name(tinfo, winfo, binfo) -- {{{
  local function strip_cwd(cwd, name)
    local rel = relpath(cwd, name)

    if not rel then
      return fnamemodify(name, ":~")
    end

    return rel
  end

  local fugitive_type = vim.b[binfo.bufnr].fugitive_type

  if fugitive_type == "blob" then -- Fugitive object
    return concat({ "[Fugitive] ", get_fugitive_object(binfo.bufnr) })
  elseif fugitive_type == "index" then -- Fugitive summary
    local name = "[Fugitive] Summary"
    local git_dir = FugitiveGitDir(binfo.bufnr):sub(1, -6)

    if git_dir ~= tinfo.cwd then
      name = concat({ name, ": ", fnamemodify(git_dir, ":~") })
    end

    return name
  elseif fugitive_type == "temp" then -- Fugitive temporary buffers
    local fugitive_result = FugitiveResult(binfo.bufnr)
    local name = concat({
      "[Fugitive]", "Git", concat(fugitive_result.args, " "), fugitive_result.blame_file
    }, " ")
    local git_dir = fugitive_result.cwd

    if git_dir ~= tinfo.cwd then
      name = concat({ pathshorten(fnamemodify(git_dir, ":~")), "$ ", name })
    end

    return name
  elseif winfo.loclist == 1 or winfo.quickfix == 1 then
    return concat({
      winfo.loclist == 1 and "[Location List] " or "[Quickfix List] ",
      get_quickfix_or_location_list_title(winfo)
    })
  end

  return strip_cwd(tinfo.cwd, binfo.name)
end -- }}}

local function get_tabs() -- {{{
  local i, p = 0, 0
  local tabs = {}
  local curtabh = vim.api.nvim_get_current_tabpage()
  local curwin = vim.api.nvim_get_current_win()
  local cwd = getcwd(-1, vim.fn.tabpagenr())

  for tabnr, tabh in ipairs(vim.api.nvim_list_tabpages()) do
    i = i + 1
    local wins = vim.api.nvim_tabpage_list_wins(tabh)
    local title_color = tabh == curtabh and BOLD_YELLOW or WHITE

    local entry = concat({
      tabh, TAB, #wins, TAB, tabnr, TAB, "", TAB,
      title_color, "Tab page ", tabnr
    })

    local tcwd = getcwd(-1, tabnr)
    entry = cwd ~= tcwd and concat({
      entry, ":", TAB,
      BOLD_CYAN, fnamemodify(tcwd, ":~"), CLEAR
    }) or concat({ entry, CLEAR })

    table.insert(tabs, entry)

    for _, w in ipairs(wins) do
      i = i + 1

      if p == 0 and tabh == curtabh and w == curwin then p = i end

      local tinfo = { cwd = tcwd }
      local winfo = getwininfo(w)[1]
      local bufnr = nvim_win_get_buf(w)
      local binfo = get_buffer_info(bufnr)

      table.insert(
        tabs,
        ("%d	%d	%d	%s		»%d	%d	%s[%d]%s	%s	%s"):format(
          tabh, w, tabnr, base64_encode(fnamemodify(tcwd, ":~")),
          tabnr, w, BLUE, bufnr, CLEAR,
          binfo.flags, get_window_name(tinfo, winfo, binfo)
        )
      )
    end
  end

  return tabs, p
end -- }}}

local function close_window(selected) -- {{{
  local function close(selected)
    local count = 0

    vim.iter(selected):each(function(s)
      local tabh, winid, tabn = get_entry_values(s)

      if winid >= 1000 then
        local success, _ = pcall(nvim_win_close, winid, false)
        if success then count = count + 1 end
      else
        local wins = winid
        local success, _ = pcall(tabclose, tabn)
        if success then count = count + wins end
      end
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
  if winid >= 1000 then
    vim.api.nvim_set_current_win(winid)
  end
end -- }}}

return function (opts)
  opts = opts or {}
  local tabs, p = get_tabs()
  local pos = string.format("pos(%d)", p)
  local fzf_cli_args = concat({
    "--ansi --multi --prompt='Tabs> '",
    concat({ "--history=", shellescape(history_file) }),
    concat(
      {
        "--bind=",
        shellescape(string.format(
          "load:%s,%s:%s,%s:reload(%s)", pos, RELOAD, pos,
          CLOSE_WINDOW, close_window_action
        ))
      }
    ),
    concat({ "--delimiter=", shellescape(TAB) }),
    "--with-nth=5..",
    concat({ "--preview=", shellescape(
      [[echo "Tab page "{3}"$(test {2} -ge 1000 && \
      { echo -n :\ && echo {4} | base64 -d - ; } || echo \ has {2} window\(s\) )"]]
    ) }),
    "--preview-window=nohidden:up,1" ,
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  coroutine.wrap(function()
    local selected = require("fzf").fzf(tabs, fzf_cli_args)

    if selected then
      jump(selected)
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
