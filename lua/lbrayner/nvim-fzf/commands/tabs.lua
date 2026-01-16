-- vim: fdm=marker

local concat = table.concat
local fnamemodify = vim.fn.fnamemodify
local getbufinfo = vim.fn.getbufinfo
local getcwd = vim.fn.getcwd
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

  for tabnr, tabh in ipairs(vim.api.nvim_list_tabpages()) do
    local cwd = getcwd(-1, tabnr)

    table.insert(
      entries,
      concat({ tabnr, 0, fnamemodify(cwd, ":~") }, TAB)
    )

    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tabh)) do
      -- From fzf-lua.providers.buffers's gen_buffer_entry
      local bufnr = vim.api.nvim_win_get_buf(w)
      local info = getbufinfo(bufnr)[1]
      local hidden = info.hidden == 1 and "h" or "a"
      local readonly = vim.bo[bufnr].readonly and "=" or " "
      local changed = info.changed == 1 and "+" or " "
      local flags = hidden .. readonly .. changed
      -- print("info", vim.inspect(info)) -- TODO debug

      -- print("info.name", vim.inspect(info.name)) -- TODO debug
      table.insert(
        entries,
        ("%d	%d	[%d]	%s	%s"):format(
          tabnr, w, bufnr, flags, strip_cwd(cwd, info.name)
        )
      )
    end
  end

  local history_file = require("lbrayner.nvim-fzf.history").get_history_file()
  local fzf_cli_args = concat({
    concat({ "--history=", shellescape(history_file) }), "--prompt='Tabs> '" ,
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  coroutine.wrap(function()
    local selected = require("fzf").fzf(entries, fzf_cli_args)

    if selected then
      -- local tabn, bufnr = tonumber(selected[1]:match("%d+"))
      local tabh, winid = selected[1]:match("^(%d+)	(%d+)")
      -- print("tabh", vim.inspect(tabh), "winid", vim.inspect(winid)) -- TODO debug

      vim.api.nvim_set_current_tabpage(tonumber(tabh))
      if tonumber(winid) > 0 then
        vim.api.nvim_set_current_win(tonumber(winid))
      end
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
