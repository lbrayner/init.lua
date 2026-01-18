-- vim: fdm=marker

local concat = table.concat
local shellescape = vim.fn.shellescape

local MOVE_DOWN = "shift-down"
local MOVE_UP   = "shift-up"

local history_file = require("lbrayner.nvim-fzf.history").get_history_file("file_marks")
local state = {}

local function get_pos() -- {{{
  local function pos(p)
    return string.format("pos(%d)", p)
  end

  -- print("marks", vim.inspect(state.marks)) -- TODO debug
  local marks = vim.split(state.marks, "\n")

  local file_mark_info = require(
    "lbrayner.marks"
  ).file_mark_info_by_bufnr[state.bufnr]

  if not file_mark_info then
    -- print("pos", 1) -- TODO debug
    return pos(1)
  end

  -- Start from position 2
  for i=3, #marks do
    if (marks[i]):match("%u") == file_mark_info.mark then
      -- local p = pos(i - 1)
      -- print("pos", vim.inspect(p)) -- TODO debug
      -- return p
      return pos(i - 1)
    end
  end
end

local get_pos_action = require("fzf.actions").raw_action(get_pos) -- }}}

local function get_marks() -- {{{
  state.marks = vim.fn.execute("marks ABCDEFGHIJKLMNOPQRSTUVWXYZ"):sub(2)
  return state.marks
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

local function move_down(args) -- {{{
  -- TODO
  print("args", vim.inspect(args)) -- TODO debug
  return vim.fn.execute("marks ABCDEFGHIJKLMNOPQRSTUVWXYZ"):sub(2)
end

local move_down_action = require("fzf.actions").raw_action(move_down) -- }}}

local function move_up() -- {{{
  -- TODO
  return vim.fn.execute("marks ABCDEFGHIJKLMNOPQRSTUVWXYZ"):sub(2)
end

local move_up_action = require("fzf.actions").raw_action(move_up) -- }}}

return function (opts)
  opts = opts or {}
  state.bufnr = vim.api.nvim_get_current_buf()
  local marks = vim.split(get_marks(), "\n")
  local fzf_cli_args = concat({
    "--header-lines=1 --multi --prompt='File marks> '",
    concat({ "--history=", shellescape(history_file) }),
    concat({
      "--bind=", shellescape(string.format(
        "load:transform(%s),ctrl-r:reload(%s),%s:reload(%s),%s:reload(%s)",
        get_pos_action, reload_action, MOVE_DOWN, move_down_action, MOVE_UP, move_up_action
      ))
    }) or nil,
    -- concat({
    --   "--expect=", shellescape(concat({ MOVE_DOWN, MOVE_UP }, ","))
    -- }),
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
