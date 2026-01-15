-- vim: fdm=marker

local concat = table.concat
local get_visual_selection = require("lbrayner").get_visual_selection
local shellescape = vim.fn.shellescape

local function get_visual_selection_query(opts) -- {{{
  local success, result = get_visual_selection(opts)

  if success then
    return result[1]
  end

  if result == 1 then
    notify("Line range not allowed, only visual selection.")
  elseif result == 2 then
    notify("Visual selection query cannot span multiple lines.")
  end
end -- }}}

return function()
  vim.api.nvim_create_user_command("NFiles", function(opts)
    local query = get_visual_selection_query(opts)

    require("lbrayner.nvim-fzf").files(
      { fzf_cli_args = concat({ "--query=", shellescape(query) }) }
    )
  end, { complete = "file", nargs = "*", range = -1 })
end
