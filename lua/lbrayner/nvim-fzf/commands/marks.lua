local concat = table.concat
local execute = vim.fn.execute
local utils = require("fzf-commands.utils")

local function jump(selected) -- {{{
  if #selected > 1 then
    vim.notify("[FZF marks] Cannot jump to multiple files", vim.log.levels.WARN)
    return
  end

  local mark = selected[1]:match("%u")
  local file_mark_info = require("lbrayner.marks").file_mark_info_by_mark[mark]
  local bufnr = file_mark_info.pos[1]
  require("lbrayner").jump_to_location(bufnr)
end -- }}}

return function (opts)
  opts = utils.normalize_opts(opts)
  local fzf_cli_args = concat({
    "--ansi --header-lines=1 --multi --prompt='File marks> '",
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  coroutine.wrap(function ()
    local marks = execute("marks ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    marks = vim.split(marks:sub(2), "\n")

    local selected = opts.fzf(marks, fzf_cli_args)
    jump(selected)
  end)()
end
