-- vim: fdm=marker

local ansi = require("lbrayner.nvim-fzf.utils").ansi
local base64_encode = vim.base64.encode
local concat = table.concat
local shellescape = vim.fn.shellescape
local truncate_filename = require("lbrayner").truncate_filename
local wrap = require("lbrayner.nvim-fzf.utils").coroutine_wrap

local RELOAD      = "ctrl-r"
local SHIFT_ABOVE = "shift-up"
local SHIFT_BELOW = "shift-down"
local SHIFT_DOWN  = "alt-shift-down"
local SHIFT_UP    = "alt-shift-up"

local BLUE = ansi.color_to_ansi("blue")
local CLEAR = ansi.clear
local GREEN = ansi.color_to_ansi("green")
local YELLOW = ansi.color_to_ansi("yellow")

local TAB = ( -- {{{
  "	") -- }}}
local history_file = require("lbrayner.nvim-fzf.history").get_history_file("file_marks")
local state = {}

local function get_pos(pos) -- {{{
  return ("pos(%d)"):format(pos)
end -- }}}

local function get_marks() -- {{{
  local success, marks = pcall(vim.fn.execute, "marks ABCDEFGHIJKLMNOPQRSTUVWXYZ")

  if not success then return end

  marks = vim.split(marks:sub(2), "\n")
  state.marks, state.pos = marks
  local header = concat({ "  ", marks[1] })
  local entries = { header }
  local _, linepos = header:find("%s+", 4)
  local _, colpos = header:find("%s+", linepos + 4)
  -- print("linepos", linepos, "colpos", colpos)--TODO debug
  local fmts = concat({
    " %s %s%-3s ",
    "%s%", linepos - 7 + 4, "s ",
    "%s%", colpos - (linepos + 5) + 3, "s%s %s"
  })

  local file_mark_info = require(
    "lbrayner.marks"
  ).file_mark_info_by_bufnr[state.bufnr]

  for i = 2, #marks do
    -- from fzf-lua's nvim provider
    local star = " "
    local mark, line, col, text = marks[i]:match("(.)%s+(%d+)%s+(%d+)%s+(.*)")

    if file_mark_info and file_mark_info.mark == mark then
      star = "★"
      state.pos = i - 1
    end

    table.insert(
      entries,
      concat({
        base64_encode(truncate_filename(text, state.width - 4)), TAB,
        string.format(fmts, star, YELLOW, mark, BLUE, line, GREEN, col, CLEAR, text)
      })
    )
  end

  return entries
end -- }}}

local reload_action = require("fzf.actions").raw_action(function()
  return get_marks() or {}
end)

local function jump(selected) -- {{{
  if #selected > 1 then
    vim.notify("[FZF marks] Cannot jump to multiple files", vim.log.levels.WARN)
    return
  end

  local mark = selected[1]:match("%s+(%u)")
  require("lbrayner.marks").file_mark_jump_to_location(mark)
end -- }}}

local set_pos_action = require("fzf.actions").raw_action(function()
  if not state.pos then return "ignore" end

  return get_pos(state.pos)
end)

local function shift_below(args) -- {{{
  return get_marks() or {}
end

local shift_below_action = require("fzf.actions").raw_action(shift_below) -- }}}

local function shift_above() -- {{{
  return get_marks() or {}
end

local shift_above_action = require("fzf.actions").raw_action(shift_above) -- }}}

local function shift_down(args) -- {{{
  return get_marks() or {}
end

local shift_down_action = require("fzf.actions").raw_action(shift_down) -- }}}

local function shift_up() -- {{{
  return get_marks() or {}
end

local shift_up_action = require("fzf.actions").raw_action(shift_up) -- }}}

return function (opts)
  local columns, lines = vim.o.columns, vim.o.lines
  local height = math.min(lines - 4, math.max(20, lines - 10))
  local width = math.min(columns - 4, math.max(80, columns - 20))

  state.bufnr = vim.api.nvim_get_current_buf()
  state.width = width

  opts = opts or {}
  local marks = get_marks() or {}
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
        state.pos and get_pos(state.pos) or "ignore", RELOAD, reload_action, set_pos_action,
        SHIFT_BELOW, shift_below_action, SHIFT_ABOVE, shift_above_action,
        SHIFT_DOWN, shift_down_action, SHIFT_UP, shift_up_action
      ))
    }),
    concat({ "--delimiter=", shellescape(TAB) }),
    "--with-nth=2..",
    concat({ "--preview=", shellescape([[echo {1} | base64 -d -]]) }),
    "--preview-window=nohidden:up,1" ,
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  wrap(function()
    local selected = require("fzf").fzf(
      marks, fzf_cli_args,
      { height = height, width = width }
    )

    if selected then
      jump(selected)
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
