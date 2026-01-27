-- vim: fdm=marker

local concat = table.concat
local get_visual_selection = require("lbrayner").get_visual_selection
local nvim_create_user_command = vim.api.nvim_create_user_command
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
  nvim_create_user_command("Buffers", function(opts)
    local query = get_visual_selection_query(opts)
    query = query and concat({ "--query=", shellescape(query) })

    require("lbrayner.nvim-fzf").buffers({
      fzf_cli_args = query
    })
  end, { nargs = "*", range = -1 })
  nvim_create_user_command("Files", function(opts)
    local query = get_visual_selection_query(opts)
    query = query and concat({ "--query=", shellescape(query) })

    require("lbrayner.nvim-fzf").files({
      fzf_cli_args = query, fzf_command_args = opts.args
    })
  end, { complete = "file", nargs = "*", range = -1 })

  nvim_create_user_command("Marks", function(opts)
    local query = get_visual_selection_query(opts)
    query = query and concat({ "--query=", shellescape(query) })

    require("lbrayner.nvim-fzf").marks({
      fzf_cli_args = query
    })
  end, { nargs = 0, range = -1 })
  nvim_create_user_command("Tabs", function(opts)
    local query = get_visual_selection_query(opts)
    query = query and concat({ "--query=", shellescape(query) })

    require("lbrayner.nvim-fzf").tabs({ fzf_cli_args = query })
  end, { nargs = 0, range = -1 })

  local opts = { silent = true }

  vim.keymap.set("n", "<F4>", function()
    require("lbrayner.nvim-fzf").marks()
  end, opts)
  vim.keymap.set("n", "<F5>", function()
    require("lbrayner.nvim-fzf").buffers()
  end, opts)
  vim.keymap.set("n", "<F7>", function()
    require("lbrayner.nvim-fzf").files()
  end, opts)
  vim.keymap.set("n", "<F8>", function()
    require("lbrayner.nvim-fzf").tabs()
  end, opts)

  require("lbrayner.nvim-fzf.ui_select").register()
end
