-- vim: fdm=marker

local ansi = require("lbrayner.nvim-fzf.utils").ansi
local concat = table.concat
local fnamemodify = vim.fn.fnamemodify
local get_buffer_info = require("lbrayner.nvim-fzf.utils").get_buffer_info
local get_quickfix_or_location_list_title = require(
  "lbrayner"
).get_quickfix_or_location_list_title
local getwininfo = vim.fn.getwininfo
local nvim_buf_delete = vim.api.nvim_buf_delete
local shellescape = vim.fn.shellescape
local tbl_isempty = vim.tbl_isempty
local wrap = require("lbrayner.nvim-fzf.utils").coroutine_wrap

local EDIT        = "ctrl-]"
local SPLIT       = "ctrl-s"
local TAB         = "ctrl-t"
local TAB_BEFORE  = "alt-t"
local VSPLIT      = "alt-s"
local WIPE_BUFFER = "ctrl-x"

local BLUE = ansi.color_to_ansi("blue")
local CLEAR = ansi.clear
local history_file = require("lbrayner.nvim-fzf.history").get_history_file()

local function edit(selected) -- {{{
  if #selected > 2 then
    vim.notify("[FZF buffers] Cannot edit multiple files", vim.log.levels.WARN)
  else
    local bufnr = tonumber(selected[2]:match("%d+"))
    vim.api.nvim_set_current_buf(bufnr)
  end
end -- }}}

local function get_buffer_name(binfo) -- {{{
  if vim.bo[binfo.bufnr].buftype == "quickfix" then
    if tbl_isempty(binfo.windows) then
      return "[Quickfix or Location List]"
    end

    local winfo = getwininfo(binfo.windows[1])[1]

    return concat({
      winfo.loclist == 1 and "[Location List] " or "[Quickfix List] ",
      get_quickfix_or_location_list_title(winfo)
    })
  elseif binfo.name == "" then
    return "[No Name]"
  end

  return fnamemodify(binfo.name, ":~:.")
end -- }}}

local function get_buffers() -- {{{
  local buffers = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local binfo = get_buffer_info(bufnr)

    table.insert(
      buffers,
      ("%s%6s%s %s %s"):format(
        BLUE, concat({ "[", bufnr, "]" }), CLEAR, binfo.flags, get_buffer_name(binfo)
      )
    )
  end

  return buffers
end -- }}}

local function jump(selected) -- {{{
  if #selected > 2 then
    vim.notify("[FZF buffers] Cannot jump to multiple buffers", vim.log.levels.WARN)
    return
  end
  local bufnr = tonumber(selected[2]:match("%d+"))
  require("lbrayner").jump_to_location(bufnr)
end -- }}}

local function wipe_buffer(selected) -- {{{
  local function wipe(selected)
    local count = 0
    -- print("wipe selected", vim.inspect(selected))--TODO debug

    vim.iter(selected):each(function(s)
      local bufnr = tonumber(s:match("%d+"))
      local success, _ = pcall(nvim_buf_delete, bufnr, {})
      if success then count = count + 1 end
    end)

    vim.notify(concat({ "[FZF buffers] Wiped ", count, " buffer(s)" }))
  end
  -- print("Selected", #selected, "items")--TODO debug

  if #selected <= 10 then
    wipe(selected)
  else
    vim.notify(
      "[FZF buffers] Wipe buffer: exceeded limit of 10 selected items",
      vim.log.levels.ERROR
    )
  end

  return get_buffers()
end

local wipe_buffer_action = require("fzf.actions").raw_action(wipe_buffer) -- }}}

return function (opts)
  opts = opts or {}
  local buffers = get_buffers()
  local fzf_cli_args = concat({
    "--ansi --multi --prompt='Buffers> '",
    concat({ "--history=", shellescape(history_file) }),
    concat({
      "--bind=",
      shellescape(string.format("%s:reload(%s)+first", WIPE_BUFFER, wipe_buffer_action))
    }),
    concat({
      "--expect=", shellescape(concat({
        EDIT, SPLIT, TAB, TAB_BEFORE, VSPLIT
      }, ","))
    }),
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  wrap(function()
    local selected = require("fzf").fzf(buffers, fzf_cli_args)
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
        elseif action == TAB then
          vicmd = "tabnew"
        elseif action == TAB_BEFORE then
          vicmd = "-tabnew"
        elseif action == VSPLIT then
          vicmd = "vnew"
        else
          jump(selected)
          return
        end

        for i = 2, #selected do
          local bufnr = tonumber(selected[i]:match("%d+"))
          -- from fzf-lua's actions (vimcmd_entry)
          vim.cmd(concat({ vicmd, " | setlocal bufhidden=wipe | buffer ", bufnr }))
        end
      end)()
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
