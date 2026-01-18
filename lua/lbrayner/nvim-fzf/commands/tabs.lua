-- vim: fdm=marker

local ansi = require("lbrayner.nvim-fzf").ansi_escseq
local base64_encode = vim.base64.encode
local concat = table.concat
local fnamemodify = vim.fn.fnamemodify
local getbufinfo = vim.fn.getbufinfo
local getcwd = vim.fn.getcwd
local nvim_win_get_buf = vim.api.nvim_win_get_buf
local relpath = vim.fs.relpath
local shellescape = vim.fn.shellescape

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
  local entries = {}
  local i, pos = 0, 0
  local curtabh = vim.api.nvim_get_current_tabpage()
  local curwin = vim.api.nvim_get_current_win()
  -- print("tabh", vim.inspect(tabh), "winid", vim.inspect(winid)) -- TODO debug

  for tabnr, tabh in ipairs(vim.api.nvim_list_tabpages()) do
    i = i + 1
    local cwd = getcwd(-1, tabnr)

    table.insert(
      entries,
      concat({
        tabnr, 0, "", concat({ ansi.white, "Tab page ", tabnr, ":" }),
        ansi.cyan, fnamemodify(cwd, ":~"), ansi.clear
      }, TAB)
    )

    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tabh)) do
      i = i + 1

      if pos == 0 and tabh == curtabh and w == curwin then pos = i end

      -- From fzf-lua.providers.buffers's gen_buffer_entry
      local bufnr = nvim_win_get_buf(w)
      local info = getbufinfo(bufnr)[1]
      local hidden = info.hidden == 1 and "h" or "a"
      local readonly = vim.bo[bufnr].readonly and "=" or " "
      local changed = info.changed == 1 and "+" or " "
      local flags = hidden .. readonly .. changed
      -- print("info", vim.inspect(info)) -- TODO debug

      -- print("info.name", vim.inspect(info.name)) -- TODO debug
      table.insert(
        entries,
        ("%d	%d	%s		»%d	%d	%s[%d]%s	%s	%s"):format(
          tabnr, w, base64_encode(fnamemodify(cwd, ":~")),
          tabnr, w, ansi.blue, bufnr, ansi.clear,
          flags, strip_cwd(cwd, info.name)
        )
      )
    end
  end

  local history_file = require("lbrayner.nvim-fzf.history").get_history_file()
  local fzf_cli_args = concat({
    "--ansi",
    concat({ "--history=", shellescape(history_file) }),
    pos > 1 and concat(
      { "--bind=", shellescape(string.format("load:pos(%d)", pos)) }
    ) or nil,
    concat({ "--delimiter=", shellescape(TAB) }),
    "--with-nth=4..",
    concat({ "--preview=", shellescape(
      'echo "Tab page "{1}"$(test {2} -gt 0 && echo -n :\\ && echo {3} | base64 -d -)"'
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
      if tonumber(winid) > 0 then
        vim.api.nvim_set_current_win(tonumber(winid))
      end
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
