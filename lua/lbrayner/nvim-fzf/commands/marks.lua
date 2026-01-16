local concat = table.concat
local get_history_file = require("lbrayner.nvim-fzf.history").get_history_file
local sanitize_history_file = require("lbrayner.nvim-fzf.history").sanitize_history_file
local shellescape = vim.fn.shellescape

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
  opts = opts or {}
  local marks = vim.fn.execute("marks ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  marks = vim.split(marks:sub(2), "\n")
  local file_mark_info, pos = require(
    "lbrayner.marks"
  ).file_mark_info_by_bufnr[vim.api.nvim_get_current_buf()]

  if file_mark_info then
    pos = (function()
      -- Start from position 2
      for i=3, #marks do
        if (marks[i]):match("%u") == file_mark_info.mark then return i end
      end
    end)()
  end

  local history_file = get_history_file("file_marks")
  local fzf_cli_args = concat({
    "--header-lines=1 --multi --prompt='File marks> '",
    concat({ "--history=", shellescape(history_file) }),
    pos and concat(
      { "--bind=", shellescape(string.format("load:pos(%d)", pos - 1)) }
    ) or nil,
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  coroutine.wrap(function()
    local selected = require("fzf").fzf(marks, fzf_cli_args)

    if selected then
      jump(selected)
    end

    sanitize_history_file(history_file)
  end)()
end
