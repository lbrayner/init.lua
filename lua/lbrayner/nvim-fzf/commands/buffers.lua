-- vim: fdm=marker

local ansi = require("lbrayner.nvim-fzf.utils").ansi
local base64_encode = vim.base64.encode
local concat = table.concat
local getcwd = vim.fn.getcwd
local fnamemodify = vim.fn.fnamemodify
local get_buffer_infos = require("lbrayner.nvim-fzf.utils").get_buffer_infos
local get_quickfix_or_location_list_title = require(
  "lbrayner"
).get_quickfix_or_location_list_title
local getwininfo = vim.fn.getwininfo
local nvim_buf_delete = vim.api.nvim_buf_delete
local relpath = require("lbrayner.nvim-fzf.utils").relpath
local shellescape = vim.fn.shellescape
local tbl_isempty = vim.tbl_isempty
local truncate_filename = require("lbrayner").truncate_filename
local wrap = require("lbrayner.nvim-fzf.utils").coroutine_wrap

local EDIT           = "ctrl-]"
local NEW_TAB        = "ctrl-t"
local NEW_TAB_BEFORE = "alt-t"
local SPLIT          = "ctrl-s"
local VSPLIT         = "alt-s"
local WIPE_BUFFER    = "ctrl-x"

local BLUE = ansi.color_to_ansi("blue")
local CLEAR = ansi.clear
local TAB = ( -- {{{
  "	") -- }}}
local history_file = require("lbrayner.nvim-fzf.history").get_history_file()
local state = {}

local function get_bufnr(selected) -- {{{
  return tonumber(selected:match("	%s*%[(%d+)%]"))
end -- }}}

local function edit(selected) -- {{{
  if #selected > 2 then
    vim.notify("[FZF buffers] Cannot edit multiple files", vim.log.levels.WARN)
  else
    local bufnr = get_bufnr(selected[2])
    vim.api.nvim_set_current_buf(bufnr)
  end
end -- }}}

local function get_buffer_display_info(binfo) -- {{{
  if vim.bo[binfo.bufnr].buftype == "quickfix" then
    if tbl_isempty(binfo.windows) then
      return { name = "[Quickfix or Location List]", type = "quickfix" }
    end

    local winfo = getwininfo(binfo.windows[1])[1]
    local name = concat({
      winfo.loclist == 1 and "[Location List] " or "[Quickfix List] ",
      get_quickfix_or_location_list_title(winfo)
    })

    return { name = name, type = "quickfix" }
  elseif binfo.name == "" then
    return { name = "[No Name]", type = "noname" }
  end

  return { name = fnamemodify(binfo.name, ":~:.") }
end -- }}}

local function get_buffers() -- {{{
  local binfos = get_buffer_infos()
  local buffers = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local binfo = binfos[bufnr]
    local dinfo = get_buffer_display_info(binfo)

    table.insert(
      buffers,
      concat({
        base64_encode(dinfo.type and dinfo.name or truncate_filename(
          relpath(getcwd(), dinfo.name) or dinfo.name, state.width - 4
        )), TAB,
        ("%s%6s%s %s %s"):format(
          BLUE, concat({ "[", bufnr, "]" }), CLEAR, binfo.flags, dinfo.name
        )
      })
    )
  end

  return buffers
end

local get_buffers_action = require("fzf.actions").raw_action(get_buffers) -- }}}

local function jump(selected) -- {{{
  if #selected > 2 then
    vim.notify("[FZF buffers] Cannot jump to multiple buffers", vim.log.levels.WARN)
    return
  end
  local bufnr = get_bufnr(selected[2])
  require("lbrayner").jump_to_location(bufnr)
end -- }}}

local function wipe_buffer(selected) -- {{{
  local function wipe(selected)
    local count = 0
    -- print("wipe selected", vim.inspect(selected))--TODO debug

    vim.iter(selected):each(function(s)
      local bufnr = get_bufnr(s)
      local success, _ = pcall(nvim_buf_delete, bufnr, {})
      if success then count = count + 1 end
    end)

    vim.notify(concat({ "[FZF buffers] Wiped ", count, " buffer(s)" }))
  end
  -- print("Selected", #selected, "items")--TODO debug

  if #selected <= 10 then
    wipe(selected)
  else
    local opts = {
      prompt = concat({
        "[FZF buffers]: Are you sure you want to wipe", #selected, "buffers? [y/N] "
      }, " ")
    }

    vim.ui.input(opts, function(input)
      input = input:lower()

      if input == "y" or input == "yes" then
        wipe(selected)
      else
        vim.notify(
          "[FZF buffers] Wipe buffer: no buffers wiped.",
          vim.log.levels.WARN
        )
      end
    end)

    return "abort"
  end

  return ("reload(%s)+first"):format(get_buffers_action)
end

local wipe_buffer_action = require("fzf.actions").raw_action(wipe_buffer) -- }}}

return function (opts)
  local columns, lines = vim.o.columns, vim.o.lines
  local height = math.min(lines - 4, math.max(20, lines - 10))
  local width = math.min(columns - 4, math.max(80, columns - 20))

  state.width = width

  opts = opts or {}
  local buffers = get_buffers()
  local fzf_cli_args = concat({
    "--ansi --multi --prompt='Buffers> '",
    concat({ "--history=", shellescape(history_file) }),
    concat({
      "--bind=",
      shellescape(string.format("%s:transform(%s)", WIPE_BUFFER, wipe_buffer_action))
    }),
    concat({
      "--expect=", shellescape(concat({
        EDIT, SPLIT, NEW_TAB, NEW_TAB_BEFORE, VSPLIT
      }, ","))
    }),
    concat({ "--delimiter=", shellescape(TAB) }),
    "--with-nth=2..",
    concat({ "--preview=", shellescape([[echo {1} | base64 -d -]]) }),
    "--preview-window=nohidden:up,1" ,
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  wrap(function()
    local opts = { height = height, width = width }
    local selected = require("fzf").fzf(buffers, fzf_cli_args, opts)
    -- print("selected", vim.inspect(selected)) -- TODO debug

    if selected then
      (function()
        local action = selected[1]
        local vicmd

        if action == EDIT then
          edit(selected)
          return
        elseif action == SPLIT then
          vicmd = "new"
        elseif action == NEW_TAB then
          vicmd = "tabnew"
        elseif action == NEW_TAB_BEFORE then
          vicmd = "-tabnew"
        elseif action == VSPLIT then
          vicmd = "vnew"
        else
          jump(selected)
          return
        end

        for i = 2, #selected do
          local bufnr = get_bufnr(selected[i])
          -- from fzf-lua's actions (vimcmd_entry)
          vim.cmd(concat({ vicmd, " | setlocal bufhidden=wipe | buffer ", bufnr }))
        end
      end)()
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
