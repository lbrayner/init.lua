-- vim: fdm=marker

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
local nvim_win_get_buf = vim.api.nvim_win_get_buf
local relpath = vim.fs.relpath
local shellescape = vim.fn.shellescape

local BLUE = ansi.color_to_ansi("blue")
local BOLD_CYAN = ansi.color_to_ansi("cyan", "bold")
local BOLD_YELLOW = ansi.color_to_ansi("yellow", "bold")
local CLEAR = ansi.clear
local WHITE = ansi.color_to_ansi("white")
local history_file = require("lbrayner.nvim-fzf.history").get_history_file()

local RELOAD    = "ctrl-r"
local TAB = ( -- {{{
  "	") -- }}}

local function get_window_name(tinfo, winfo, binfo) -- {{{
  local function strip_cwd(cwd, name)
    local rel = relpath(cwd, name)

    if not rel then
      return fnamemodify(name, ":~")
    end

    return rel
  end

  if winfo.loclist == 1 or winfo.quickfix == 1 then
    return concat(
      {
        winfo.loclist == 1 and "[Location List]" or "[Quickfix List] ",
        get_quickfix_or_location_list_title(winfo.winid)
      }
    )
  end

  return strip_cwd(tinfo.cwd, binfo.name)
end -- }}}

return function (opts)
  opts = opts or {}
  local cwd = getcwd(-1, vim.fn.tabpagenr())
  local entries = {}
  local i, p = 0, 0
  local curtabh = vim.api.nvim_get_current_tabpage()
  local curwin = vim.api.nvim_get_current_win()
  -- print("tabh", vim.inspect(tabh), "winid", vim.inspect(winid)) -- TODO debug

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

    table.insert(entries, entry)

    for _, w in ipairs(wins) do
      i = i + 1

      if p == 0 and tabh == curtabh and w == curwin then p = i end

      local tinfo = { cwd = tcwd }
      local winfo = getwininfo(w)[1]
      local bufnr = nvim_win_get_buf(w)
      local binfo = get_buffer_info(bufnr)

      table.insert(
        entries,
        ("%d	%d	%d	%s		»%d	%d	%s[%d]%s	%s	%s"):format(
          tabh, w, tabnr, base64_encode(fnamemodify(tcwd, ":~")),
          tabnr, w, BLUE, bufnr, CLEAR,
          binfo.flags, get_window_name(tinfo, winfo, binfo)
        )
      )
    end
  end

  local pos = string.format("pos(%d)", p)

  local fzf_cli_args = concat({
    "--ansi --prompt='Tabs> '",
    concat({ "--history=", shellescape(history_file) }),
    concat(
      { "--bind=", shellescape(string.format("load:%s,%s:%s", pos, RELOAD, pos)) }
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
    local selected = require("fzf").fzf(entries, fzf_cli_args)
    -- print("selected", vim.inspect(selected)) -- TODO debug

    if selected then
      local tabh, winid = selected[1]:match(concat({ "^(%d+)", TAB, "(%d+)" }))
      tabh, winid = tonumber(tabh), tonumber(winid)
      -- print("tabh", vim.inspect(tabh), "winid", vim.inspect(winid)) -- TODO debug

      vim.api.nvim_set_current_tabpage(tabh)
      if winid >= 1000 then
        vim.api.nvim_set_current_win(winid)
      end
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
