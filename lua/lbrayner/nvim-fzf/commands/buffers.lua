-- vim: fdm=marker

local ansi = require("lbrayner.nvim-fzf.utils").ansi
local concat = table.concat
local fnamemodify = vim.fn.fnamemodify
local get_buffer_info = require("lbrayner.nvim-fzf.utils").get_buffer_info
local shellescape = vim.fn.shellescape

local BLUE = ansi.color_to_ansi("blue")
local CLEAR = ansi.clear
local history_file = require("lbrayner.nvim-fzf.history").get_history_file()

local function jump(selected) -- {{{
  local bufnr = tonumber(selected[1]:match("%d+"))
  require("lbrayner").jump_to_location(bufnr)
end -- }}}

return function (opts)
  opts = opts or {}
  local entries = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local info = get_buffer_info(bufnr)

    table.insert(
      entries,
      ("%s[%d]%s	%s	%s"):format(
        BLUE, bufnr, CLEAR,
        info.flags, fnamemodify(info.name, ":~:.")
      )
    )
  end

  local fzf_cli_args = concat({
    "--ansi --prompt='Buffers> '",
    concat({ "--history=", shellescape(history_file) }),
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  coroutine.wrap(function()
    local selected = require("fzf").fzf(entries, fzf_cli_args)
    -- print("selected", vim.inspect(selected)) -- TODO debug

    if selected then
      jump(selected)
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
