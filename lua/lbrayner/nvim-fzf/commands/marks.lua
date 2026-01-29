-- vim: fdm=marker

local ansi = require("lbrayner.nvim-fzf.utils").ansi
local concat = table.concat
local shellescape = vim.fn.shellescape

local RELOAD      = "ctrl-r"
local SHIFT_ABOVE = "shift-up"
local SHIFT_BELOW = "shift-down"
local SHIFT_DOWN  = "alt-shift-down"
local SHIFT_UP    = "alt-shift-up"

local BLUE = ansi.color_to_ansi("blue")
local CLEAR = ansi.clear
local GREEN = ansi.color_to_ansi("green")
local YELLOW = ansi.color_to_ansi("yellow")
local history_file = require("lbrayner.nvim-fzf.history").get_history_file("file_marks")
local state = {}

local function get_pos() -- {{{
  local file_mark_info = require(
    "lbrayner.marks"
  ).file_mark_info_by_bufnr[state.bufnr]
  -- print("file_mark_info", vim.inspect(file_mark_info)) -- TODO debug

  if not file_mark_info then
    -- print("pos", 1) -- TODO debug
    return "ignore"
  end

  return string.format("pos(%d)", file_mark_info.index)
end

local get_pos_action = require("fzf.actions").raw_action(get_pos) -- }}}

local function get_marks() -- {{{
  local marks = vim.split(vim.fn.execute("marks ABCDEFGHIJKLMNOPQRSTUVWXYZ"):sub(2), "\n")
  local header = marks[1]
  local entries = { header }
  local _, linepos = header:find("%s+", 4)
  local _, colpos = header:find("%s+", linepos + 4)
  -- print("linepos", linepos, "colpos", colpos)--TODO debug
  local fmts = concat({
    " %s%-3s ",
    "%s%", linepos - 5 + 4, "s ",
    "%s%", colpos - (linepos + 5) + 3, "s%s %s"
  })

  for i = 2, #marks do
    -- from fzf-lua's nvim provider
    local mark, line, col, text = marks[i]:match("(.)%s+(%d+)%s+(%d+)%s+(.*)")

    table.insert(
      entries, string.format(fmts, YELLOW, mark, BLUE, line, GREEN, col, CLEAR, text)
    )
  end

  return entries
end

local reload_action = require("fzf.actions").raw_action(get_marks) -- }}}

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

local function shift_below(args) -- {{{
  -- TODO
  print("args", vim.inspect(args)) -- TODO debug
  return vim.fn.execute("marks ABCDEFGHIJKLMNOPQRSTUVWXYZ"):sub(2)
end

local shift_below_action = require("fzf.actions").raw_action(shift_below) -- }}}

local function shift_above() -- {{{
  -- TODO
  return vim.fn.execute("marks ABCDEFGHIJKLMNOPQRSTUVWXYZ"):sub(2)
end

local shift_above_action = require("fzf.actions").raw_action(shift_above) -- }}}

local function shift_down(args) -- {{{
  -- TODO
  print("args", vim.inspect(args)) -- TODO debug
  return vim.fn.execute("marks ABCDEFGHIJKLMNOPQRSTUVWXYZ"):sub(2)
end

local shift_down_action = require("fzf.actions").raw_action(shift_down) -- }}}

local function shift_up() -- {{{
  -- TODO
  return vim.fn.execute("marks ABCDEFGHIJKLMNOPQRSTUVWXYZ"):sub(2)
end

local shift_up_action = require("fzf.actions").raw_action(shift_up) -- }}}

return function (opts)
  opts = opts or {}
  state.bufnr = vim.api.nvim_get_current_buf()
  local marks = get_marks()
  local fzf_cli_args = concat({
    "--ansi --header-lines=1 --multi --sync --prompt='File marks> '",
    concat({ "--history=", shellescape(history_file) }),
    concat({
      "--bind=", shellescape(string.format(
        concat({
          "start:%s", "%s:reload(%s)+transform(%s)",
          "%s:reload(%s)", "%s:reload(%s)",
          "%s:reload(%s)", "%s:reload(%s)",
        }, ","),
        get_pos(), RELOAD, reload_action, get_pos_action,
        SHIFT_BELOW, shift_below_action, SHIFT_ABOVE, shift_above_action,
        SHIFT_DOWN, shift_down_action, SHIFT_UP, shift_up_action
      ))
    }),
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  coroutine.wrap(function()
    local selected = require("fzf").fzf(marks, fzf_cli_args)

    if selected then
      jump(selected)
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
