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

  local prompt = ui_opts.prompt or "Select one of> "
  local history_file = require("lbrayner.nvim-fzf.history").get_history_file("ui_select")
  local fzf_cli_args = concat({
    concat({ "--history=", shellescape(history_file) }),
    concat({ "--prompt=", shellescape(prompt) })
  }, " ")

  local function select()
    local selected = require("fzf").fzf(entries, fzf_cli_args)
    -- print("selected", vim.inspect(selected)) -- TODO debug

    if selected then
      local idx = tonumber(selected[1]:match("%d+"))
      on_choice(items[idx])
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end

  local co = coroutine.running()

  if co then
    select()
  else
    coroutine.wrap(function()
      select()
    end)()
  end
end

return M
