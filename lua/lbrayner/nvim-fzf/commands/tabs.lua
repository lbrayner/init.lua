local concat = table.concat
local get_history_file = require("lbrayner.nvim-fzf.history").get_history_file
local get_path = require("lbrayner.path").get_path
local sanitize_history_file = require("lbrayner.nvim-fzf.history").sanitize_history_file
local shellescape = vim.fn.shellescape

return function (opts)
  opts = opts or {}
  local entries = {}

  for tabnr, tabh in ipairs(vim.api.nvim_list_tabpages()) do
    table.insert(
      entries,
      concat({ "Tab #", tabnr })
    )

    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tabh)) do
      -- From fzf-lua.providers.buffers's gen_buffer_entry
      local bufnr = vim.api.nvim_win_get_buf(w)
      local info = vim.fn.getbufinfo(bufnr)
      local hidden = info.hidden == 1 and "h" or "a"
      local readonly = vim.bo[bufnr].readonly and "=" or " "
      local changed = info.changed == 1 and "+" or " "
      local flags = hidden .. readonly .. changed

      table.insert(
        entries,
        ("%d	[%d]	%s	%s"):format(
          tabnr, bufnr, flags, get_path(bufnr)
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
      jump(selected)
    end

    sanitize_history_file(history_file)
  end)()
end
