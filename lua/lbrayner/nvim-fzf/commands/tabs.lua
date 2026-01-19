-- vim: fdm=marker

local ansi = require("lbrayner.nvim-fzf.utils").ansi
local base64_encode = vim.base64.encode
local concat = table.concat
local fnamemodify = vim.fn.fnamemodify
local get_buffer_info = require("lbrayner.nvim-fzf.utils").get_buffer_info
local getcwd = vim.fn.getcwd
local nvim_win_get_buf = vim.api.nvim_win_get_buf
local relpath = vim.fs.relpath
local shellescape = vim.fn.shellescape

local BLUE = ansi.color_to_ansi("blue")
local BOLD_CYAN = ansi.color_to_ansi("cyan", "bold")
local CLEAR = ansi.clear
local WHITE = ansi.color_to_ansi("white")
local history_file = require("lbrayner.nvim-fzf.history").get_history_file()

local TAB = ( -- {{{
  "	") -- }}}

local function strip_cwd(cwd, name) -- {{{
  local rel = relpath(cwd, name)

  if not rel then
    return fnamemodify(name, ":~")
  end

  return rel
end -- }}}

return function (opts)
  opts = opts or {}
  local cwd = getcwd(-1, vim.fn.tabpagenr())
  local entries = {}
  local i, pos = 0, 0
  local curtabh = vim.api.nvim_get_current_tabpage()
  local curwin = vim.api.nvim_get_current_win()
  -- print("tabh", vim.inspect(tabh), "winid", vim.inspect(winid)) -- TODO debug

  for tabnr, tabh in ipairs(vim.api.nvim_list_tabpages()) do
    i = i + 1
    local tcwd = getcwd(-1, tabnr)
    local wins = vim.api.nvim_tabpage_list_wins(tabh)
    local entry = concat({
      tabh, TAB, #wins, TAB, tabnr, TAB, "", TAB,
      WHITE, "Tab page ", tabnr
    })

    if cwd ~= tcwd then
      entry = concat({
        entry, ":", TAB,
        BOLD_CYAN, fnamemodify(tcwd, ":~"), CLEAR
      })
    end

    table.insert(entries, entry)

    for _, w in ipairs(wins) do
      i = i + 1

      if pos == 0 and tabh == curtabh and w == curwin then pos = i end

      local bufnr = nvim_win_get_buf(w)
      local info = get_buffer_info(bufnr)

      table.insert(
        entries,
        ("%d	%d	%d	%s		»%d	%d	%s[%d]%s	%s	%s"):format(
          tabh, w, tabnr, base64_encode(fnamemodify(tcwd, ":~")),
          tabnr, w, BLUE, bufnr, CLEAR,
          info.flags, strip_cwd(tcwd, info.name)
        )
      )
    end
  end

  local fzf_cli_args = concat({
    "--ansi --prompt='Tabs> '",
    concat({ "--history=", shellescape(history_file) }),
    pos > 1 and concat(
      { "--bind=", shellescape(string.format("load:pos(%d)", pos)) }
    ) or nil,
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
      -- local tabn, bufnr = tonumber(selected[1]:match("%d+"))
      local tabh, winid = selected[1]:match(concat({ "^(%d+)", TAB, "(%d+)" }))
      -- print("tabh", vim.inspect(tabh), "winid", vim.inspect(winid)) -- TODO debug

      vim.api.nvim_set_current_tabpage(tonumber(tabh))
      if tonumber(winid) >= 1000 then
        vim.api.nvim_set_current_win(tonumber(winid))
      end
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
