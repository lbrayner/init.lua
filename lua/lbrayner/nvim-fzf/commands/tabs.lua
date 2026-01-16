-- vim: fdm=marker

local concat = table.concat
local fnamemodify = vim.fn.fnamemodify
local get_history_file = require("lbrayner.nvim-fzf.history").get_history_file
local getcwd = vim.fn.getcwd
local sanitize_history_file = require("lbrayner.nvim-fzf.history").sanitize_history_file
local shellescape = vim.fn.shellescape
local startswith = vim.startswith

local function strip_cwd(tabnr, name) -- {{{
  -- print("tabnr", vim.inspect(tabnr), "name", vim.inspect(name)) -- TODO debug
  local cwd = getcwd(-1, tabnr)
  -- print("cwd", vim.inspect(cwd), "name", vim.inspect(name)) -- TODO debug
  name = fnamemodify(name, ":p")
  -- print("name", vim.inspect(name)) -- TODO debug

  if not startswith(name, cwd) then
    return fnamemodify(name, ":~")
  end

  -- print("name", vim.inspect(name), "cwd", vim.inspect(cwd)) -- TODO debug
  return name:sub(#cwd + 2)
end -- }}}

return function (opts)
  opts = opts or {}
  local entries = {}

  for tabnr, tabh in ipairs(vim.api.nvim_list_tabpages()) do
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tabh)) do
      -- From fzf-lua.providers.buffers's gen_buffer_entry
      local bufnr = vim.api.nvim_win_get_buf(w)
      local info = vim.fn.getbufinfo(bufnr)[1]
      local hidden = info.hidden == 1 and "h" or "a"
      local readonly = vim.bo[bufnr].readonly and "=" or " "
      local changed = info.changed == 1 and "+" or " "
      local flags = hidden .. readonly .. changed
      -- print("info", vim.inspect(info)) -- TODO debug

      -- print("info.name", vim.inspect(info.name)) -- TODO debug
      table.insert(
        entries,
        ("%d	%d	[%d]	%s	%s"):format(
          tabnr, w, bufnr, flags, strip_cwd(tabnr, info.name)
        )
      )
    end
  end

  local history_file = get_history_file()
  local fzf_cli_args = concat({
    concat({ "--history=", shellescape(history_file) }), "--prompt='Tabs> '" ,
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  coroutine.wrap(function()
    local selected = require("fzf").fzf(entries, fzf_cli_args)

    if selected then
      -- local tabn, bufnr = tonumber(selected[1]:match("%d+"))
      jump(selected)
    end

    sanitize_history_file(history_file)
  end)()
end
