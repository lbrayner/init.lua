local concat = table.concat
local shellescape = vim.fn.shellescape

local M = {}

_OLD_UI_SELECT = nil

function M.register()
  _OLD_UI_SELECT = _OLD_UI_SELECT or vim.ui.select
  vim.ui.select = M.ui_select
end

function M.ui_select(items, ui_opts, on_choice)
  local entries = {}
  for i, e in ipairs(items) do
    table.insert(
      entries,
      ("%d. %s"):format(
        i,
        ui_opts.format_item and ui_opts.format_item(e) or tostring(e)
      )
    )
  end

  local prompt = ui_opts.prompt or "Select one of>"
  local fzf_cli_args = concat({
    concat({ "--prompt=", shellescape(prompt) }),
  }, " ")

  coroutine.wrap(function ()
    local selected = require("fzf").fzf(entries, fzf_cli_args)
    -- print("selected", vim.inspect(selected)) -- TODO debug

    if not selected then return end

    local idx = tonumber(selected[1]:match("%d"))
    -- print("idx", vim.inspect(idx), "items", vim.inspect(items), "items[idx]", vim.inspect(items[idx])) -- TODO debug

    on_choice(items[idx])
  end)()
end

return M
